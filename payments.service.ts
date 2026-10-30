import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';
import { PaymentMethod, PaymentStatus, OrderStatus } from '@prisma/client';
import { CreateTransfermovilPaymentDto } from './dto/create-transfermovil.dto';
import { CreateCryptoPaymentDto } from './dto/create-crypto.dto';
import { VerifyTransfermovilDto } from './dto/verify-transfermovil.dto';
import { ConfigService } from '@nestjs/config';
import { TronService } from './tron.service';

@Injectable()
export class PaymentsService {
  constructor(
    private prisma: PrismaService,
    private config: ConfigService,
    private tron: TronService,
  ) {}

  // ─────────────────────────────────────────────
  // TRANSFERMÓVIL – Crear pago + mostrar datos
  // ─────────────────────────────────────────────
  async createTransfermovilPayment(
    orderId: string,
    userId: string,
    dto: CreateTransfermovilPaymentDto,
  ) {
    const order = await this.prisma.order.findFirst({
      where: { id: orderId, userId },
      include: { payment: true },
    });

    if (!order) throw new NotFoundException('Pedido no encontrado');
    if (order.payment) {
      throw new BadRequestException('Este pedido ya tiene un pago iniciado');
    }

    const isCUP = dto.method === PaymentMethod.TRANSFERMOVIL_CUP;
    const card = isCUP
      ? this.config.get<string>('TRANSFERMOVIL_CUP_CARD')
      : this.config.get<string>('TRANSFERMOVIL_MLC_CARD');

    if (!card) {
      throw new BadRequestException(
        'Tarjeta de destino no configurada en el servidor',
      );
    }

    const amount = isCUP ? order.totalCUP : order.totalMLC;
    if (!amount) {
      throw new BadRequestException(
        `El pedido no tiene total en ${isCUP ? 'CUP' : 'MLC'}`,
      );
    }

    const payment = await this.prisma.payment.create({
      data: {
        orderId,
        method: dto.method,
        status: PaymentStatus.PENDING,
        amount,
        currency: isCUP ? 'CUP' : 'MLC',
        transfermovilCard: card,
        expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24), // 24h
      },
    });

    await this.prisma.order.update({
      where: { id: orderId },
      data: {
        paymentMethod: dto.method,
        status: OrderStatus.PENDING_PAYMENT,
      },
    });

    return {
      paymentId: payment.id,
      orderNumber: order.orderNumber,
      method: dto.method,
      amount: amount.toString(),
      currency: isCUP ? 'CUP' : 'MLC',
      cardNumber: card,
      instructions: [
        '1. Abre Transfermóvil y autentícate con BANDEC',
        '2. Ve a Operaciones → Transferencia',
        `3. Transfiere exactamente ${amount} ${isCUP ? 'CUP' : 'MLC'} a la tarjeta: ${card}`,
        `4. En la descripción escribe: ${order.orderNumber}`,
        '5. Guarda el SMS de confirmación',
        '6. Sube una captura del SMS o del comprobante en la app/web',
      ],
      expiresAt: payment.expiresAt,
    };
  }

  // ─────────────────────────────────────────────
  // TRANSFERMÓVIL – Cliente sube comprobante
  // ─────────────────────────────────────────────
  async uploadProof(
    paymentId: string,
    userId: string,
    proofImageUrl: string,
    customerReference?: string,
  ) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
      include: { order: true },
    });

    if (!payment) throw new NotFoundException('Pago no encontrado');
    if (payment.order.userId !== userId) {
      throw new ForbiddenException('No tienes permiso sobre este pago');
    }
    if (
      payment.method !== PaymentMethod.TRANSFERMOVIL_CUP &&
      payment.method !== PaymentMethod.TRANSFERMOVIL_MLC
    ) {
      throw new BadRequestException('Este pago no es de Transfermóvil');
    }

    const updated = await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        proofImageUrl,
        customerReference,
        status: PaymentStatus.AWAITING_VERIFICATION,
      },
    });

    await this.prisma.order.update({
      where: { id: payment.orderId },
      data: { status: OrderStatus.PENDING_VERIFICATION },
    });

    return {
      message: 'Comprobante recibido. El equipo lo verificará pronto.',
      status: updated.status,
    };
  }

  // ─────────────────────────────────────────────
  // TRANSFERMÓVIL – Admin aprueba o rechaza
  // ─────────────────────────────────────────────
  async verifyTransfermovil(
    paymentId: string,
    adminId: string,
    dto: VerifyTransfermovilDto,
  ) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
      include: { order: true },
    });

    if (!payment) throw new NotFoundException('Pago no encontrado');
    if (payment.status !== PaymentStatus.AWAITING_VERIFICATION) {
      throw new BadRequestException(
        'Este pago no está esperando verificación',
      );
    }

    if (dto.approved) {
      await this.prisma.$transaction([
        this.prisma.payment.update({
          where: { id: paymentId },
          data: {
            status: PaymentStatus.CONFIRMED,
            verifiedById: adminId,
            verifiedAt: new Date(),
            adminNotes: dto.notes,
          },
        }),
        this.prisma.order.update({
          where: { id: payment.orderId },
          data: { status: OrderStatus.PAID },
        }),
      ]);

      // Aquí se puede disparar notificación push/email al cliente
      return { message: 'Pago aprobado correctamente', status: 'PAID' };
    } else {
      await this.prisma.$transaction([
        this.prisma.payment.update({
          where: { id: paymentId },
          data: {
            status: PaymentStatus.FAILED,
            verifiedById: adminId,
            verifiedAt: new Date(),
            adminNotes: dto.notes || 'Rechazado por el administrador',
          },
        }),
        this.prisma.order.update({
          where: { id: payment.orderId },
          data: { status: OrderStatus.CANCELLED },
        }),
      ]);

      return { message: 'Pago rechazado', status: 'CANCELLED' };
    }
  }

  // ─────────────────────────────────────────────
  // CRYPTO – Crear pago TRX / USDT
  // ─────────────────────────────────────────────
  async createCryptoPayment(
    orderId: string,
    userId: string,
    dto: CreateCryptoPaymentDto,
  ) {
    const order = await this.prisma.order.findFirst({
      where: { id: orderId, userId },
      include: { payment: true },
    });

    if (!order) throw new NotFoundException('Pedido no encontrado');
    if (order.payment) {
      throw new BadRequestException('Este pedido ya tiene un pago iniciado');
    }

    const isUSDT = dto.method === PaymentMethod.USDT_TRC20;
    const amount = order.totalUSDT;
    if (!amount) {
      throw new BadRequestException('El pedido no tiene precio en USDT');
    }

    // En producción se puede generar una dirección única por pedido
    // (usando una HD wallet). Aquí usamos una dirección fija + referencia.
    const depositAddress = this.config.get<string>('TRON_WALLET_ADDRESS');
    if (!depositAddress) {
      throw new BadRequestException('Wallet TRON no configurada');
    }

    const payment = await this.prisma.payment.create({
      data: {
        orderId,
        method: dto.method,
        status: PaymentStatus.PENDING,
        amount,
        currency: isUSDT ? 'USDT' : 'TRX',
        cryptoAddress: depositAddress,
        cryptoAmountExpected: amount,
        expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 2), // 2 horas
      },
    });

    await this.prisma.order.update({
      where: { id: orderId },
      data: {
        paymentMethod: dto.method,
        status: OrderStatus.PENDING_PAYMENT,
      },
    });

    return {
      paymentId: payment.id,
      orderNumber: order.orderNumber,
      method: dto.method,
      amount: amount.toString(),
      currency: isUSDT ? 'USDT' : 'TRX',
      network: 'TRC20',
      depositAddress,
      memo: order.orderNumber, // el cliente debe poner esto si la wallet lo permite
      expiresAt: payment.expiresAt,
      note: 'Envía exactamente el monto indicado. El sistema detectará el pago automáticamente.',
    };
  }

  // ─────────────────────────────────────────────
  // CRYPTO – Worker de monitoreo (llamado por cron)
  // ─────────────────────────────────────────────
  async checkPendingCryptoPayments() {
    const pending = await this.prisma.payment.findMany({
      where: {
        method: { in: [PaymentMethod.TRX, PaymentMethod.USDT_TRC20] },
        status: PaymentStatus.PENDING,
        expiresAt: { gt: new Date() },
      },
      include: { order: true },
    });

    for (const payment of pending) {
      try {
        const result = await this.tron.checkIncomingTransfer({
          address: payment.cryptoAddress!,
          expectedAmount: payment.cryptoAmountExpected!.toString(),
          currency: payment.currency as 'TRX' | 'USDT',
          since: payment.createdAt,
        });

        if (result.found) {
          await this.prisma.$transaction([
            this.prisma.payment.update({
              where: { id: payment.id },
              data: {
                status: PaymentStatus.CONFIRMED,
                cryptoTxId: result.txid,
                cryptoAmountReceived: result.amount,
                cryptoConfirmations: result.confirmations,
              },
            }),
            this.prisma.order.update({
              where: { id: payment.orderId },
              data: { status: OrderStatus.PAID },
            }),
          ]);
          // Notificar al cliente
        }
      } catch (err) {
        console.error(`Error checking payment ${payment.id}:`, err);
      }
    }
  }

  // ─────────────────────────────────────────────
  // Listar pagos pendientes de verificación (Admin)
  // ─────────────────────────────────────────────
  async getPendingVerifications() {
    return this.prisma.payment.findMany({
      where: { status: PaymentStatus.AWAITING_VERIFICATION },
      include: {
        order: {
          include: {
            user: { select: { firstName: true, lastName: true, phone: true } },
            items: { include: { product: true } },
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });
  }
}

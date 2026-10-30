import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrderStatus } from '@prisma/client';
import { randomBytes } from 'crypto';

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  private generateOrderNumber(): string {
    const date = new Date();
    const y = date.getFullYear().toString().slice(-2);
    const m = (date.getMonth() + 1).toString().padStart(2, '0');
    const d = date.getDate().toString().padStart(2, '0');
    const rand = randomBytes(3).toString('hex').toUpperCase();
    return `ORD-${y}${m}${d}-${rand}`;
  }

  async create(userId: string, dto: CreateOrderDto) {
    if (!dto.items || dto.items.length === 0) {
      throw new BadRequestException('El pedido debe tener al menos un producto');
    }

    const productIds = dto.items.map((i) => i.productId);
    const products = await this.prisma.product.findMany({
      where: { id: { in: productIds }, isActive: true },
    });

    if (products.length !== productIds.length) {
      throw new BadRequestException('Uno o más productos no existen');
    }

    let totalCUP = 0;
    let totalMLC = 0;
    let totalUSDT = 0;

    const orderItemsData = dto.items.map((item) => {
      const product = products.find((p) => p.id === item.productId)!;
      if (product.stock < item.quantity) {
        throw new BadRequestException(
          `Stock insuficiente para ${product.name}`,
        );
      }
      const unitPrice = Number(product.priceCUP);
      const totalPrice = unitPrice * item.quantity;
      totalCUP += totalPrice;
      if (product.priceMLC) totalMLC += Number(product.priceMLC) * item.quantity;
      if (product.priceUSDT)
        totalUSDT += Number(product.priceUSDT) * item.quantity;

      return {
        productId: product.id,
        quantity: item.quantity,
        unitPrice,
        totalPrice,
      };
    });

    const order = await this.prisma.$transaction(async (tx) => {
      // Reducir stock
      for (const item of dto.items) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { decrement: item.quantity } },
        });
      }

      return tx.order.create({
        data: {
          orderNumber: this.generateOrderNumber(),
          userId,
          status: OrderStatus.PENDING_PAYMENT,
          totalCUP,
          totalMLC: totalMLC || null,
          totalUSDT: totalUSDT || null,
          shippingAddress: dto.shippingAddress || {},
          notes: dto.notes,
          items: {
            create: orderItemsData,
          },
        },
        include: {
          items: { include: { product: true } },
        },
      });
    });

    return order;
  }

  async findByUser(userId: string) {
    return this.prisma.order.findMany({
      where: { userId },
      include: {
        items: { include: { product: true } },
        payment: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string, userId?: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        items: { include: { product: true } },
        payment: true,
        user: {
          select: { id: true, firstName: true, lastName: true, email: true, phone: true },
        },
      },
    });
    if (!order) throw new NotFoundException('Pedido no encontrado');
    if (userId && order.userId !== userId) {
      throw new NotFoundException('Pedido no encontrado');
    }
    return order;
  }

  async findAllAdmin(status?: OrderStatus) {
    return this.prisma.order.findMany({
      where: status ? { status } : undefined,
      include: {
        items: { include: { product: true } },
        payment: true,
        user: {
          select: { firstName: true, lastName: true, email: true, phone: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateStatus(id: string, status: OrderStatus) {
    return this.prisma.order.update({
      where: { id },
      data: { status },
    });
  }
}

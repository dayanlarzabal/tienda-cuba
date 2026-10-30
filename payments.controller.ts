import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  UseGuards,
  Request,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { PaymentsService } from './payments.service';
import { CreateTransfermovilPaymentDto } from './dto/create-transfermovil.dto';
import { CreateCryptoPaymentDto } from './dto/create-crypto.dto';
import { VerifyTransfermovilDto } from './dto/verify-transfermovil.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('payments')
@UseGuards(JwtAuthGuard)
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  // Cliente: iniciar pago Transfermóvil
  @Post('transfermovil/:orderId')
  createTransfermovil(
    @Param('orderId') orderId: string,
    @Request() req: any,
    @Body() dto: CreateTransfermovilPaymentDto,
  ) {
    return this.paymentsService.createTransfermovilPayment(
      orderId,
      req.user.id,
      dto,
    );
  }

  // Cliente: subir comprobante (screenshot)
  @Post('transfermovil/:paymentId/proof')
  @UseInterceptors(FileInterceptor('proof'))
  async uploadProof(
    @Param('paymentId') paymentId: string,
    @Request() req: any,
    @UploadedFile() file: Express.Multer.File,
    @Body('customerReference') customerReference?: string,
  ) {
    // En producción: subir a MinIO/S3 y obtener URL
    const proofImageUrl = file
      ? `/uploads/proofs/${file.filename}`
      : undefined;

    if (!proofImageUrl) {
      throw new Error('Debes subir una imagen del comprobante');
    }

    return this.paymentsService.uploadProof(
      paymentId,
      req.user.id,
      proofImageUrl,
      customerReference,
    );
  }

  // Cliente: iniciar pago crypto
  @Post('crypto/:orderId')
  createCrypto(
    @Param('orderId') orderId: string,
    @Request() req: any,
    @Body() dto: CreateCryptoPaymentDto,
  ) {
    return this.paymentsService.createCryptoPayment(
      orderId,
      req.user.id,
      dto,
    );
  }

  // Admin: listar pagos pendientes de verificación
  @Get('pending-verification')
  @UseGuards(RolesGuard)
  @Roles('ADMIN', 'SUPER_ADMIN')
  getPending() {
    return this.paymentsService.getPendingVerifications();
  }

  // Admin: aprobar / rechazar Transfermóvil
  @Post('verify/:paymentId')
  @UseGuards(RolesGuard)
  @Roles('ADMIN', 'SUPER_ADMIN')
  verify(
    @Param('paymentId') paymentId: string,
    @Request() req: any,
    @Body() dto: VerifyTransfermovilDto,
  ) {
    return this.paymentsService.verifyTransfermovil(
      paymentId,
      req.user.id,
      dto,
    );
  }
}

import { IsEnum } from 'class-validator';
import { PaymentMethod } from '@prisma/client';

export class CreateTransfermovilPaymentDto {
  @IsEnum([PaymentMethod.TRANSFERMOVIL_CUP, PaymentMethod.TRANSFERMOVIL_MLC])
  method: PaymentMethod.TRANSFERMOVIL_CUP | PaymentMethod.TRANSFERMOVIL_MLC;
}

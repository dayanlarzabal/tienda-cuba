import { IsEnum } from 'class-validator';
import { PaymentMethod } from '@prisma/client';

export class CreateCryptoPaymentDto {
  @IsEnum([PaymentMethod.TRX, PaymentMethod.USDT_TRC20])
  method: PaymentMethod.TRX | PaymentMethod.USDT_TRC20;
}

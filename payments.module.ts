import { Module } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { TronService } from './tron.service';
import { PrismaService } from '../../common/prisma.service';
import { ScheduleModule } from '@nestjs/schedule';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Injectable } from '@nestjs/common';

@Injectable()
export class CryptoMonitorService {
  constructor(private paymentsService: PaymentsService) {}

  // Cada 45 segundos revisa pagos crypto pendientes
  @Cron(CronExpression.EVERY_30_SECONDS)
  async handleCron() {
    await this.paymentsService.checkPendingCryptoPayments();
  }
}

@Module({
  imports: [ScheduleModule.forRoot()],
  controllers: [PaymentsController],
  providers: [PaymentsService, TronService, PrismaService, CryptoMonitorService],
  exports: [PaymentsService],
})
export class PaymentsModule {}

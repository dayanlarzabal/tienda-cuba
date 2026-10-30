import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Servicio de integración con la red TRON (TRC20).
 * Usa TronGrid API.
 *
 * En producción se recomienda:
 * - Usar una HD wallet y generar direcciones únicas por pedido
 * - O usar un servicio como TronPay / NowPayments
 * - Configurar webhooks de TronGrid en lugar de solo polling
 */
@Injectable()
export class TronService {
  private readonly logger = new Logger(TronService.name);
  private readonly apiKey: string;
  private readonly usdtContract = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'; // USDT TRC20 mainnet

  constructor(private config: ConfigService) {
    this.apiKey = this.config.get<string>('TRON_API_KEY') || '';
  }

  async checkIncomingTransfer(params: {
    address: string;
    expectedAmount: string;
    currency: 'TRX' | 'USDT';
    since: Date;
  }): Promise<{
    found: boolean;
    txid?: string;
    amount?: string;
    confirmations?: number;
  }> {
    try {
      if (params.currency === 'USDT') {
        return this.checkUSDT(params);
      } else {
        return this.checkTRX(params);
      }
    } catch (error) {
      this.logger.error('Error checking Tron transfer', error);
      return { found: false };
    }
  }

  private async checkUSDT(params: {
    address: string;
    expectedAmount: string;
    since: Date;
  }) {
    // TronGrid: GET /v1/accounts/{address}/transactions/trc20
    const url = `https://api.trongrid.io/v1/accounts/${params.address}/transactions/trc20?limit=20&contract_address=${this.usdtContract}`;

    const res = await fetch(url, {
      headers: {
        'TRON-PRO-API-KEY': this.apiKey,
      },
    });

    if (!res.ok) {
      this.logger.warn(`TronGrid USDT response: ${res.status}`);
      return { found: false };
    }

    const data = await res.json();
    const expected = parseFloat(params.expectedAmount);

    for (const tx of data.data || []) {
      const to = tx.to;
      const value = parseFloat(tx.value) / 1e6; // USDT tiene 6 decimales
      const timestamp = tx.block_timestamp;

      if (
        to?.toLowerCase() === params.address.toLowerCase() &&
        Math.abs(value - expected) < 0.01 && // tolerancia pequeña
        timestamp >= params.since.getTime()
      ) {
        return {
          found: true,
          txid: tx.transaction_id,
          amount: value.toString(),
          confirmations: 20, // simplificado
        };
      }
    }

    return { found: false };
  }

  private async checkTRX(params: {
    address: string;
    expectedAmount: string;
    since: Date;
  }) {
    const url = `https://api.trongrid.io/v1/accounts/${params.address}/transactions?limit=20&only_to=true`;

    const res = await fetch(url, {
      headers: {
        'TRON-PRO-API-KEY': this.apiKey,
      },
    });

    if (!res.ok) return { found: false };

    const data = await res.json();
    const expected = parseFloat(params.expectedAmount);

    for (const tx of data.data || []) {
      // Tron nativo: value está en sun (1 TRX = 1_000_000 sun)
      const contract = tx.raw_data?.contract?.[0];
      if (contract?.type !== 'TransferContract') continue;

      const value = parseFloat(contract.parameter?.value?.amount || '0') / 1e6;
      const timestamp = tx.block_timestamp;

      if (
        Math.abs(value - expected) < 0.001 &&
        timestamp >= params.since.getTime()
      ) {
        return {
          found: true,
          txid: tx.txID,
          amount: value.toString(),
          confirmations: 20,
        };
      }
    }

    return { found: false };
  }
}

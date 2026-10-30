import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentCryptoScreen extends StatelessWidget {
  final String orderId;
  const PaymentCryptoScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo – en producción vienen del backend
    const address = 'TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
    const amount = '25.50';
    const currency = 'USDT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con Crypto'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Envía exactamente',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '$amount $currency',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Red: TRC20 (Tron)', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 32),
            const Text('Dirección de depósito', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(child: SelectableText(address, style: const TextStyle(fontFamily: 'monospace'))),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dirección copiada')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'El sistema detectará el pago automáticamente en unos minutos.\nNo cierres esta pantalla hasta que se confirme.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

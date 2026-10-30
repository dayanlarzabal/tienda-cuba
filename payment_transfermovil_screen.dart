import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentTransfermovilScreen extends StatefulWidget {
  final String orderId;
  const PaymentTransfermovilScreen({super.key, required this.orderId});

  @override
  State<PaymentTransfermovilScreen> createState() =>
      _PaymentTransfermovilScreenState();
}

class _PaymentTransfermovilScreenState
    extends State<PaymentTransfermovilScreen> {
  String? _method; // CUP or MLC
  Map<String, dynamic>? _paymentData;
  bool _loading = false;
  File? _proofImage;
  final _referenceController = TextEditingController();
  bool _uploading = false;

  Future<void> _startPayment(String method) async {
    setState(() {
      _loading = true;
      _method = method;
    });

    try {
      // TODO: reemplazar con tu base URL y token JWT
      final response = await http.post(
        Uri.parse('https://api.tu-dominio.com/payments/transfermovil/${widget.orderId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer TU_JWT_TOKEN',
        },
        body: jsonEncode({
          'method': method == 'CUP'
              ? 'TRANSFERMOVIL_CUP'
              : 'TRANSFERMOVIL_MLC',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _paymentData = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickProof() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _proofImage = File(picked.path));
    }
  }

  Future<void> _uploadProof() async {
    if (_proofImage == null || _paymentData == null) return;

    setState(() => _uploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://api.tu-dominio.com/payments/transfermovil/${_paymentData!['paymentId']}/proof',
        ),
      );
      request.headers['Authorization'] = 'Bearer TU_JWT_TOKEN';
      request.files.add(
        await http.MultipartFile.fromPath('proof', _proofImage!.path),
      );
      if (_referenceController.text.isNotEmpty) {
        request.fields['customerReference'] = _referenceController.text;
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Comprobante enviado'),
              content: const Text(
                'Tu pago está en revisión. Te notificaremos cuando sea verificado.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // volver
                  },
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con Transfermóvil'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: _paymentData == null
          ? _buildMethodSelector()
          : _buildPaymentInstructions(),
    );
  }

  Widget _buildMethodSelector() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selecciona la moneda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _MethodCard(
            title: 'Transfermóvil CUP',
            subtitle: 'Pesos cubanos',
            icon: Icons.attach_money,
            color: Colors.green,
            loading: _loading && _method == 'CUP',
            onTap: () => _startPayment('CUP'),
          ),
          const SizedBox(height: 16),
          _MethodCard(
            title: 'Transfermóvil MLC',
            subtitle: 'Moneda libremente convertible',
            icon: Icons.currency_exchange,
            color: Colors.blue,
            loading: _loading && _method == 'MLC',
            onTap: () => _startPayment('MLC'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    final data = _paymentData!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monto destacado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Monto a transferir', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '${data['amount']} ${data['currency']}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066CC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tarjeta destino
          const Text('Tarjeta de destino (BANDEC)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data['cardNumber'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: data['cardNumber'] ?? ''),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tarjeta copiada')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Referencia
          Text(
            'Referencia del pedido: ${data['orderNumber']}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escribe esta referencia en la descripción de la transferencia',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Instrucciones
          const Text('Pasos a seguir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...(data['instructions'] as List? ?? []).map<Widget>((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(step.toString())),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Subir comprobante
          const Text('Sube el comprobante',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Número de referencia / Autorizo (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_proofImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_proofImage!, height: 180, fit: BoxFit.cover),
            )
          else
            OutlinedButton.icon(
              onPressed: _pickProof,
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar captura del SMS'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _proofImage != null && !_uploading ? _uploadProof : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
            child: _uploading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enviar comprobante'),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

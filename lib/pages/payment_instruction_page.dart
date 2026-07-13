import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class PaymentInstructionPage extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const PaymentInstructionPage({super.key, required this.paymentData});

  @override
  State<PaymentInstructionPage> createState() => _PaymentInstructionPageState();
}

class _PaymentInstructionPageState extends State<PaymentInstructionPage> {
  bool _isPaid = false;
  bool _isLoading = false;
  String _paymentStatus = 'pending';
  int _checkCount = 0;

  String get _transactionId {
    final data = widget.paymentData;
    return (data['id'] ?? data['transaction_id'] ?? data['transaction']['id'] ?? '').toString();
  }

  String get _amount {
    final data = widget.paymentData;
    return (data['total_price'] ?? data['amount'] ?? '0').toString();
  }

  String get _status {
    final data = widget.paymentData;
    return (data['status'] ?? 'pending').toString();
  }

  String get _paymentMethod {
    final data = widget.paymentData;
    if (data['payment_method'] != null && data['payment_method'] is Map) {
      return data['payment_method']['payment_name'] ?? 'QRIS';
    }
    if (data['payment'] != null && data['payment'] is Map) {
      return data['payment']['payment_name'] ?? 'QRIS';
    }
    return data['payment_method_name'] ?? data['payment_name'] ?? 'QRIS';
  }

  String get _gameName {
    final data = widget.paymentData;
    if (data['game'] != null && data['game'] is Map) {
      return data['game']['game_name'] ?? 'Game';
    }
    return data['game_name'] ?? 'Game';
  }

  String get _diamondAmount {
    final data = widget.paymentData;
    if (data['denomination'] != null && data['denomination'] is Map) {
      return data['denomination']['diamond_amount']?.toString() ?? '0';
    }
    return data['diamond_amount']?.toString() ?? '0';
  }

  @override
  void initState() {
    super.initState();
    _paymentStatus = _status;
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    if (_isPaid || _checkCount > 20) return;

    _checkCount++;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (_transactionId.isEmpty) {
        print('Transaction ID not found');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.transactions}/$_transactionId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      print('Status Payment: ${response.statusCode}');
      print('Response: $data');

      if (response.statusCode == 200) {
        final status = data['data']?['status']?.toString().toLowerCase() ?? 'pending';
        
        if (mounted) {
          setState(() {
            _paymentStatus = status;
          });
        }

        if (status == 'success' || status == 'completed' || status == 'paid') {
          if (mounted) {
            setState(() {
              _isPaid = true;
            });
          }
          
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home', arguments: 3);
            }
          });
          return;
        }
      }
    } catch (e) {
      print('Error checking payment: $e');
    }

    if (!_isPaid && mounted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _checkPaymentStatus();
        }
      });
    }
  }

  Future<void> _checkManual() async {
    setState(() {
      _isLoading = true;
    });
    _checkCount = 0;
    await _checkPaymentStatus();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruksi Pembayaran'),
        backgroundColor: _isPaid ? Colors.green : const Color(0xFF7C3AED),
        actions: [
          if (_isPaid)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.check_circle, color: Colors.white),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== STATUS ==========
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isPaid ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPaid ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPaid ? Icons.check_circle : Icons.hourglass_empty,
                    color: _isPaid ? Colors.green : Colors.orange,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isPaid 
                        ? ' Pembayaran Berhasil!' 
                        : ' Menunggu Pembayaran...',
                      style: TextStyle(
                        color: _isPaid ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

          
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text(
                    'RINGKASAN PEMBAYARAN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detailRow('Game', _gameName),
                  _detailRow('Diamond', '$_diamondAmount '),
                  _detailRow('Total Pembayaran', 'Rp ${_formatPrice(_amount)}'),
                  _detailRow('Metode', _paymentMethod),
                  _detailRow('Status', _paymentStatus.toUpperCase()),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Scan QR Code untuk Membayar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildQRCode(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ' Instruksi Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep('1', 'Buka aplikasi pembayaran ($_paymentMethod)'),
                  _buildInstructionStep('2', 'Pilih menu Scan QR Code atau Transfer'),
                  _buildInstructionStep('3', 'Konfirmasi pembayaran dan tunggu proses'),
                  _buildInstructionStep('4', 'Status akan otomatis berubah setelah pembayaran berhasil'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_isPaid)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home', arguments: 3);
                },
                child: const Text('Lihat Riwayat Transaksi'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isLoading ? null : _checkManual,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Cek Status Pembayaran'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCode() {

    String qrData = '';

    qrData = widget.paymentData['qr_code']?.toString() ?? '';
    if (qrData.isEmpty) qrData = widget.paymentData['qr_string']?.toString() ?? '';
    if (qrData.isEmpty) qrData = widget.paymentData['payment_url']?.toString() ?? '';
    if (qrData.isEmpty) qrData = widget.paymentData['qr']?.toString() ?? '';
    if (qrData.isEmpty && widget.paymentData['payment'] != null) {
      final payment = widget.paymentData['payment'] as Map?;
      qrData = payment?['qr_code']?.toString() ?? '';
    }
    if (qrData.isEmpty && widget.paymentData['transaction'] != null) {
      final transaction = widget.paymentData['transaction'] as Map?;
      qrData = transaction?['qr_code']?.toString() ?? '';
    }

    if (qrData.isEmpty) {
      return const Column(
        children: [
          Icon(Icons.qr_code, size: 150, color: Colors.black26),
          SizedBox(height: 8),
          Text(
            'QR Code tidak tersedia',
            style: TextStyle(color: Colors.black38),
          ),
          SizedBox(height: 4),
          Text(
            'Silakan cek metode pembayaran Anda',
            style: TextStyle(color: Colors.black26, fontSize: 12),
          ),
        ],
      );
    }

    if (qrData.startsWith('http')) {
      return Image.network(
        qrData,
        width: 180,
        height: 180,
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            children: [
              Icon(Icons.qr_code, size: 150, color: Colors.black26),
              Text('Gagal memuat QR Code'),
            ],
          );
        },
      );
    }

    if (qrData.startsWith('data:image')) {
      try {
        final base64String = qrData.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 180,
          height: 180,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              children: [
                Icon(Icons.qr_code, size: 150, color: Colors.black26),
                Text('Gagal memuat QR Code'),
              ],
            );
          },
        );
      } catch (e) {
        return const Column(
          children: [
            Icon(Icons.qr_code, size: 150, color: Colors.black26),
            Text('Format QR tidak valid'),
          ],
        );
      }
    }

    return Center(
      child: Container(
        width: 200,
        height: 200,
        color: Colors.white,
        child: Center(
          child: Text(
            'QR: $qrData',
            style: const TextStyle(color: Colors.black, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final number = double.tryParse(price) ?? 0;
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
    } catch (e) {
      return price;
    }
  }
}
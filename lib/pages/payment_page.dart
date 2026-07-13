import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic>? transactionData;
  
  const PaymentPage({super.key, this.transactionData});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPayment = 'QRIS';
  bool _isLoading = false;
  int get _gameId => widget.transactionData?['game_id'] ?? 1;
  String get _gameUserId => widget.transactionData?['game_user_id'] ?? '123456789';
  int get _denominationId => widget.transactionData?['denomination_id'] ?? 1;
  String get _gameName => widget.transactionData?['game_name'] ?? 'Mobile Legends';
  String get _diamondAmount => widget.transactionData?['diamond_amount']?.toString() ?? '86';
  String get _price => widget.transactionData?['price']?.toString() ?? '20000';

  final _paymentOptions = <Map<String, dynamic>>[
    {'label': 'QRIS', 'icon': Icons.qr_code, 'group': 'E-Wallet', 'id': 1},
    {'label': 'DANA', 'icon': Icons.account_balance_wallet, 'group': 'E-Wallet', 'id': 2},
    {'label': 'OVO', 'icon': Icons.account_balance_wallet, 'group': 'E-Wallet', 'id': 3},
    {'label': 'GoPay', 'icon': Icons.phone_android, 'group': 'E-Wallet', 'id': 4},
    {'label': 'ShopeePay', 'icon': Icons.shopping_bag, 'group': 'E-Wallet', 'id': 5},
    {'label': 'BCA Virtual Account', 'icon': Icons.account_balance, 'group': 'Virtual Account', 'id': 6},
    {'label': 'BNI Virtual Account', 'icon': Icons.account_balance, 'group': 'Virtual Account', 'id': 7},
    {'label': 'Mandiri Virtual Account', 'icon': Icons.account_balance, 'group': 'Virtual Account', 'id': 8},
    {'label': 'Alfamart', 'icon': Icons.store, 'group': 'Convenience Store', 'id': 9},
  ];

  int _getPaymentMethodId(String label) {
    for (var item in _paymentOptions) {
      if (item['label'] == label) {
        return item['id'] as int;
      }
    }
    return 1;
  }

  Future<void> _processPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      _showSnackbar('Silakan login terlebih dahulu', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentMethodId = _getPaymentMethodId(_selectedPayment);
      final body = {
        'game_id': _gameId,
        'game_user_id': _gameUserId,
        'denomination_id': _denominationId,
        'payment_method_id': paymentMethodId,
      };

      print('=== REQUEST PAYMENT ===');
      print('URL: ${ApiConfig.transactions}');
      print('Body: $body');
      print('Token: $token');

      final response = await http.post(
        Uri.parse(ApiConfig.transactions),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print('Response Payment: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showSnackbar('Pembayaran berhasil!', Colors.green);
          
          // Navigasi ke halaman instruksi pembayaran
          Navigator.pushReplacementNamed(
            context, 
            '/payment_instruction',
            arguments: data['data'],
          );
        }
      } else {
        if (mounted) {
          String errorMsg = data['message'] ?? 'Pembayaran gagal';
          if (data['data'] is List) {
            errorMsg = (data['data'] as List).map((e) => e['message']).join(', ');
          }
          _showSnackbar(errorMsg, Colors.red);
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        _showSnackbar('Gagal memproses pembayaran: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Pembayaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Kembali ke Beranda',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _paymentSection(
                      'E-Wallet',
                      _paymentOptions.where((item) => item['group'] == 'E-Wallet').toList(),
                    ),
                    const SizedBox(height: 20),
                    _paymentSection(
                      'Virtual Account',
                      _paymentOptions.where((item) => item['group'] == 'Virtual Account').toList(),
                    ),
                    const SizedBox(height: 20),
                    _paymentSection(
                      'Convenience Store',
                      _paymentOptions.where((item) => item['group'] == 'Convenience Store').toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'RINGKASAN PEMBAYARAN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.gamepad,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _gameName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _detailRow('ID Game', _gameUserId),
                        _detailRow('Nominal', '$_diamondAmount Diamond'),
                        _detailRow('Metode', _selectedPayment),
                        _detailRow('Harga', 'Rp ${_formatPrice(_price)}'),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 12),
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${_formatPrice(_price)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _paymentContinueSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: items.map((item) {
            final label = item['label'] as String;
            final icon = item['icon'] as IconData;
            final selected = label == _selectedPayment;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedPayment = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF111827) : const Color(0xFF0B1227),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? const Color(0xFF7C3AED) : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: const Color(0xFF7C3AED),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF7C3AED),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _paymentContinueSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Lanjutkan Pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Metode yang dipilih: $_selectedPayment',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pastikan metode pembayaran sesuai, lalu lanjutkan untuk melihat instruksi dan kode pembayaran.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7C3AED),
                  ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _processPayment,
                  child: const Text(
                    'Bayar Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
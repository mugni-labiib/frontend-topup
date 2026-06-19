import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPayment = 'QRIS';

  final _paymentOptions = <Map<String, dynamic>>[
    {'label': 'QRIS', 'icon': Icons.qr_code, 'group': 'E-Wallet'},
    {'label': 'DANA', 'icon': Icons.account_balance_wallet, 'group': 'E-Wallet'},
    {'label': 'OVO', 'icon': Icons.account_balance_wallet, 'group': 'E-Wallet'},
    {'label': 'GoPay', 'icon': Icons.phone_android, 'group': 'E-Wallet'},
    {'label': 'ShopeePay', 'icon': Icons.shopping_bag, 'group': 'E-Wallet'},
    {'label': 'BCA Virtual Account', 'icon': Icons.account_balance, 'group': 'Virtual Account'},
    {'label': 'BNI Virtual Account', 'icon': Icons.account_balance, 'group': 'Virtual Account'},
    {'label': 'Mandiri Virtual Account', 'icon': Icons.account_balance, 'group': 'Virtual Account'},
    {'label': 'Alfamart', 'icon': Icons.store, 'group': 'Convenience Store'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
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
                    const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 22),
                    _paymentSection('E-Wallet', _paymentOptions.where((item) => item['group'] == 'E-Wallet').toList()),
                    const SizedBox(height: 20),
                    _paymentSection('Virtual Account', _paymentOptions.where((item) => item['group'] == 'Virtual Account').toList()),
                    const SizedBox(height: 20),
                    _paymentSection('Convenience Store', _paymentOptions.where((item) => item['group'] == 'Convenience Store').toList()),
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
                        const Text('RINGKASAN PEMBAYARAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.gamepad, color: Color(0xFF7C3AED)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Mobile Legends', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _detailRow('ID Game', '123456789 (1234)'),
                        _detailRow('Nominal', '86 Diamond'),
                        _detailRow('Metode', _selectedPayment),
                        _detailRow('Harga', 'Rp 20.000'),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 12),
                        const Text('Total Pembayaran', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        const Text('Rp 20.000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
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
        Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
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
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF111827) : const Color(0xFF0B1227),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: selected ? const Color(0xFF7C3AED) : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                      if (selected) const Icon(Icons.check_circle, color: Color(0xFF7C3AED))
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
          const Text('Lanjutkan Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Metode yang dipilih: $_selectedPayment', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          const Text('Pastikan metode pembayaran sesuai, lalu lanjutkan untuk melihat instruksi dan kode pembayaran.', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () => Navigator.pushNamed(context, '/riwayat'),
            child: const Text('Lanjutkan ke Riwayat'),
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
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

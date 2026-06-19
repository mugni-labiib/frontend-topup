import 'package:flutter/material.dart';

class TopUpFormPage extends StatefulWidget {
  const TopUpFormPage({super.key});

  @override
  State<TopUpFormPage> createState() => _TopUpFormPageState();
}

class _TopUpFormPageState extends State<TopUpFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _gameIdController = TextEditingController();
  final _promoController = TextEditingController();
  final _contactController = TextEditingController();
  final String _selectedGame = 'Mobile Legends';
  int _selectedDiamond = 86;

  final _diamondOptions = [86, 172, 257, 344, 429, 514];

  @override
  void dispose() {
    _gameIdController.dispose();
    _promoController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priceMap = {86: 20000, 172: 40000, 257: 60000, 344: 80000, 429: 100000, 514: 120000};
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up / Detail Game')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
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
                            Row(
                              children: [
                                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white70)),
                                const SizedBox(width: 8),
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.gamepad, color: Color(0xFF7C3AED)),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(child: Text('Mobile Legends Bang Bang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text('1. Masukkan ID Game', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _gameIdController,
                              decoration: const InputDecoration(hintText: 'Masukkan ID Game kamu'),
                              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 14),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 8),
                            const Text('2. Pilih Nominal Diamond', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3 / 4,
                              physics: const NeverScrollableScrollPhysics(),
                              children: _diamondOptions.map((d) {
                                final selected = d == _selectedDiamond;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedDiamond = d),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: selected ? const Color(0xFF0B1227) : const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: selected ? const Color(0xFF7C3AED) : Colors.white12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.diamond, color: Color(0xFF7C3AED), size: 36),
                                        const SizedBox(height: 8),
                                        Text('$d Diamond', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        Text('Rp ${priceMap[d]!.toString()}', style: const TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Align(alignment: Alignment.center, child: TextButton(onPressed: () {}, child: const Text('Lihat semua nominal'))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 360,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('RINGKASAN ORDER', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.gamepad, color: Color(0xFF7C3AED))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_selectedGame, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  _summaryRow('ID Game', _gameIdController.text.isEmpty ? '-' : _gameIdController.text),
                  _summaryRow('Nominal', '$_selectedDiamond Diamond'),
                  _summaryRow('Harga', 'Rp ${priceMap[_selectedDiamond]!.toString()}'),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  const Text('Total', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('Rp ${priceMap[_selectedDiamond]!.toString()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      Navigator.pushNamed(context, '/payment');
                    },
                    child: const Text('Beli Sekarang'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _summaryRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

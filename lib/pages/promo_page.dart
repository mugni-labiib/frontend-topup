import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final promoItems = const [
      PromoItem(
        title: 'Diskon 10%',
        subtitle: 'Top Up Diamond Mobile Legends\nMinimal top up 86 Diamond',
        color: Color(0xFF8B5CF6),
      ),
      PromoItem(
        title: 'Cashback 5%',
        subtitle: 'Semua Metode Pembayaran\nMinimal top up Rp 50.000',
        color: Color(0xFF10B981),
      ),
      PromoItem(
        title: 'Promo Weekend',
        subtitle: 'Diskon s/d 15%\nSetiap Sabtu - Minggu',
        color: Color(0xFF3B82F6),
      ),
      PromoItem(
        title: 'Combo Hemat',
        subtitle: 'Paket bundling best seller\nHemat sampai 20%',
        color: Color(0xFFEC4899),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Promo Spesial', actionLabel: 'Lihat Semua Promo'),
          const SizedBox(height: 16),
          Column(
            children: promoItems.map((promo) => PromoCard(item: promo)).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gunakan promo di atas saat checkout dan nikmati diskon terbaik tiap hari.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

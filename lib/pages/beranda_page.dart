import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    const popularGames = [
      'Mobile Legends',
      'Free Fire',
      'PUBG Mobile',
      'Valorant',
      'Genshin Impact',
    ];

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
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF151B36), Color(0xFF0D1228)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('TOP UP DIAMOND', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          Text('GAME FAVORITMU!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1)),
                          SizedBox(height: 12),
                          Text('Proses cepat, aman, dan harga terbaik', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.shield, color: Color(0xFF7C3AED), size: 42),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    FeatureChip(icon: Icons.flash_on, title: 'Proses Cepat', subtitle: '1-3 Menit'),
                    FeatureChip(icon: Icons.security, title: '100% Aman', subtitle: 'Garansi Resmi'),
                    FeatureChip(icon: Icons.headset_mic, title: 'CS 24/7', subtitle: 'Siap Membantu'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Game Populer', actionLabel: 'Lihat Semua'),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: popularGames.length,
              separatorBuilder: (_, ____) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return GameCard(gameName: popularGames[index]);
              },
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Promo Spesial', actionLabel: 'Lihat Semua Promo'),
          const SizedBox(height: 16),
          Column(
            children: promoItems.map((promo) => PromoCard(item: promo)).toList(),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Keunggulan', actionLabel: 'Lihat Semua'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AdvantageTile(icon: Icons.flash_on, label: 'Proses Cepat'),
              AdvantageTile(icon: Icons.payment, label: 'Pembayaran Lengkap'),
              AdvantageTile(icon: Icons.thumb_up, label: 'Harga Terbaik'),
            ],
          ),
        ],
      ),
    );
  }
}

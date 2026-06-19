import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final popularGames = const [
      GameInfo(name: 'Mobile Legends', subtitle: 'Bang Bang', icon: Icons.gamepad, accent: Color(0xFF6D28D9)),
      GameInfo(name: 'Free Fire', subtitle: '', icon: Icons.local_fire_department, accent: Color(0xFFEF4444)),
      GameInfo(name: 'PUBG Mobile', subtitle: '', icon: Icons.sports_esports, accent: Color(0xFF1E3A8A)),
      GameInfo(name: 'Genshin Impact', subtitle: '', icon: Icons.auto_awesome, accent: Color(0xFF8B5CF6)),
      GameInfo(name: 'Valorant', subtitle: '', icon: Icons.shield, accent: Color(0xFFDC2626)),
      GameInfo(name: 'Clash of Clans', subtitle: '', icon: Icons.vpn_lock, accent: Color(0xFFF59E0B)),
      GameInfo(name: 'Brawl Stars', subtitle: '', icon: Icons.flash_on, accent: Color(0xFFEF4444)),
      GameInfo(name: 'Honkai Star Rail', subtitle: '', icon: Icons.rocket_launch, accent: Color(0xFF8B5CF6)),
    ];

    final allGames = const [
      GameInfo(name: 'AOV', subtitle: 'Arena of Valor', icon: Icons.sports_martial_arts, accent: Color(0xFF2563EB)),
      GameInfo(name: 'Call of Duty Mobile', subtitle: '', icon: Icons.shield, accent: Color(0xFF0F766E)),
      GameInfo(name: 'Ragnarok Origin', subtitle: '', icon: Icons.castle, accent: Color(0xFF9333EA)),
      GameInfo(name: 'League of Legends', subtitle: '', icon: Icons.sports_motorsports, accent: Color(0xFF2563EB)),
    ];

    final chipLabels = const ['Semua', 'Popular', 'Mobile Game', 'PC Game', 'Console Game'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari game favoritmu...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: chipLabels.map((label) {
                      final selected = label == 'Semua';
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF5B21B6) : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: selected ? const Color(0xFF7C3AED) : Colors.white12),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Game Populer', actionLabel: 'Lihat Semua'),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularGames.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 228,
            ),
            itemBuilder: (context, index) {
              return PopularGameCard(game: popularGames[index]);
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Semua Game', actionLabel: 'Lihat Semua'),
          const SizedBox(height: 16),
          Column(
            children: allGames.map((game) => GameListItem(game: game)).toList(),
          ),
        ],
      ),
    );
  }
}

class GameInfo {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const GameInfo({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

class PopularGameCard extends StatefulWidget {
  final GameInfo game;

  const PopularGameCard({super.key, required this.game});

  @override
  State<PopularGameCard> createState() => _PopularGameCardState();
}

class _PopularGameCardState extends State<PopularGameCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovering ? const Color(0xFF7C3AED) : Colors.white12),
        ),
        child: Column(
          children: [
            Expanded(child: Center(child: Icon(widget.game.icon, size: 48, color: widget.game.accent))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text(widget.game.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: widget.game.accent),
                    onPressed: () => Navigator.pushNamed(context, '/topup'),
                    child: const Text('Top Up'),
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

class GameListItem extends StatefulWidget {
  final GameInfo game;

  const GameListItem({super.key, required this.game});

  @override
  State<GameListItem> createState() => _GameListItemState();
}

class _GameListItemState extends State<GameListItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _hovering ? const Color(0xFF162047) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hovering ? const Color(0xFF7C3AED) : Colors.white10),
          boxShadow: _hovering ? [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8))] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.game.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.game.icon, size: 28, color: widget.game.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.game.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (widget.game.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(widget.game.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: () => Navigator.pushNamed(context, '/topup'),
              child: const Text('Top Up'),
            ),
          ],
        ),
      ),
    );
  }
}

// Duplicate GameListItem removed (interactive version above is used)

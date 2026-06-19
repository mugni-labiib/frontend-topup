import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Bantuan', actionLabel: 'Hubungi CS'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Ada masalah atau pertanyaan?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('Tim customer service siap membantu kamu kapan saja. Gunakan chat atau email di bawah ini.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.chat, color: Color(0xFF7C3AED)),
            title: Text('Live Chat'),
            subtitle: Text('Chat langsung dengan tim support'),
            tileColor: Color(0xFF111827),
          ),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(Icons.email, color: Color(0xFF7C3AED)),
            title: Text('Email Support'),
            subtitle: Text('support@topupzone.id'),
            tileColor: Color(0xFF111827),
          ),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(Icons.help_outline, color: Color(0xFF7C3AED)),
            title: Text('FAQ'),
            subtitle: Text('Pertanyaan yang sering ditanyakan'),
            tileColor: Color(0xFF111827),
          ),
        ],
      ),
    );
  }
}

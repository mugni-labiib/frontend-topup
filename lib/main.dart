import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/beranda_page.dart';
import 'pages/game_page.dart';
import 'pages/promo_page.dart';
import 'pages/riwayat_page.dart';
import 'pages/bantuan_page.dart';
import 'pages/topup_page.dart';
import 'pages/payment_page.dart';
import 'pages/login_page.dart';
import 'pages/payment_instruction_page.dart'; // ← TAMBAHKAN IMPORT

void main() {
  runApp(const TopUpZoneFormApp());
}

class TopUpZoneFormApp extends StatelessWidget {
  const TopUpZoneFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TopUpZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1320),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101827),
          elevation: 0,
        ),
        cardColor: const Color(0xFF111827),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF141A2B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/home': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
        '/topup': (context) => const TopUpFormPage(),
        '/beranda': (context) => const BerandaPage(),
        '/game': (context) => const GamePage(),
        '/promo': (context) => const PromoPage(),
        '/riwayat': (context) => const RiwayatPage(),
        '/bantuan': (context) => const BantuanPage(),
      },
      // ✅ onGenerateRoute untuk menangani arguments
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            final args = settings.arguments as int? ?? 0;
            return MaterialPageRoute(
              builder: (context) => MainPage(initialTabIndex: args),
            );
          
          case '/payment':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PaymentPage(transactionData: args),
            );
          
          case '/payment_instruction':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PaymentInstructionPage(paymentData: args),
            );
          
          default:
            return null;
        }
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final int initialTabIndex;

  const MainPage({super.key, this.initialTabIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0B1227),
          flexibleSpace: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            alignment: Alignment.center,
            child: Row(
              children: [
                // Logo
                InkWell(
                  onTap: () {
                    if (_tabController.index != 0) {
                      _tabController.animateTo(0);
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.bolt, color: Color(0xFF7C3AED), size: 28),
                      SizedBox(width: 8),
                      Text(
                        'TOPUPZONE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Expanded(
                  child: Center(
                    child: IntrinsicWidth(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: const Color(0xFF7C3AED),
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: const [
                          Tab(text: 'Beranda'),
                          Tab(text: 'Game'),
                          Tab(text: 'Promo'),
                          Tab(text: 'Riwayat'),
                          Tab(text: 'Bantuan'),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tombol Logout
                TextButton(
                  onPressed: () async {
                    // Hapus token saat logout
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');
                    await prefs.remove('user');
                    
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BerandaPage(),
          GamePage(),
          PromoPage(),
          RiwayatPage(),
          BantuanPage(),
        ],
      ),
    );
  }
}
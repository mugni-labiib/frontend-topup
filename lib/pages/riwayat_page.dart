import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Tambahkan base URL
const String baseUrl = 'http://10.0.2.2:5000'; // Ganti sesuai environment

class RiwayatPage extends StatefulWidget {
  final bool isAdmin;

  const RiwayatPage({super.key, this.isAdmin = false});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final tabs = const ['Semua', 'Berhasil', 'Pending', 'Gagal'];
  String selectedTab = 'Semua';

  List<dynamic> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRiwayatDariBackend();
  }

  Future<void> fetchRiwayatDariBackend() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/riwayat'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Koneksi timeout, coba lagi nanti');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data is List) {
            orders = data;
          } else if (data['success'] == true && data['data'] is List) {
            orders = data['data'];
          } else {
            orders = [];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data dari server (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Tidak bisa terhubung ke server. Error: $e';
        isLoading = false;
      });
      print('Error fetching riwayat: $e');
    }
  }

  List<dynamic> get filteredOrders {
    if (selectedTab == 'Semua') return orders;
    return orders.where((order) => (order['status'] ?? 'Pending') == selectedTab).toList();
  }

  Color statusColor(String status) {
    if (status == 'Berhasil') return const Color(0xFF10B981);
    if (status == 'Pending') return const Color(0xFFF59E0B);
    if (status == 'Gagal') return const Color(0xFFEF4444);
    return Colors.white70;
  }

  Color statusBackgroundColor(String status) {
    if (status == 'Berhasil') return const Color.fromRGBO(16, 185, 129, 0.16);
    if (status == 'Pending') return const Color.fromRGBO(245, 158, 11, 0.16);
    if (status == 'Gagal') return const Color.fromRGBO(239, 68, 68, 0.16);
    return const Color.fromRGBO(255, 255, 255, 0.12);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Transaksi', 
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.indigoAccent),
                onPressed: fetchRiwayatDariBackend,
                tooltip: 'Refresh Data',
              )
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: tabs.map((tab) {
              final selected = tab == selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedTab = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF7C3AED) : const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? Colors.transparent : Colors.white10),
                    ),
                    child: Center(
                      child: Text(
                        tab, 
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70, 
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Order ID', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Game', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Nominal', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Harga', style: _headerStyle())),
                Expanded(flex: 2, child: Container(alignment: Alignment.center, child: Text('Status', style: _headerStyle()))),
                Expanded(flex: 2, child: Container(alignment: Alignment.centerRight, child: Text('Waktu', style: _headerStyle()))),
                if (widget.isAdmin) Expanded(flex: 1, child: Text('Aksi', style: _headerStyle())),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 16),
                            Text(errorMessage, style: const TextStyle(color: Colors.redAccent)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: fetchRiwayatDariBackend,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : filteredOrders.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, color: Colors.white38, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  '📭 Belum ada riwayat transaksi.',
                                  style: TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredOrders.length,
                            separatorBuilder: (context, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              String idOrder = order['id']?.toString() ?? order['orderId']?.toString() ?? '#TZ0000';
                              String namaGame = order['game'] ?? order['gameName'] ?? '-';
                              String nominal = order['nominal']?.toString() ?? '-';
                              String statusStr = order['status'] ?? 'Pending';
                              String waktuStr = order['waktu'] ?? order['createdAt'] ?? 'Baru Saja';
                              
                              String hargaStr = order['harga'] != null 
                                  ? 'Rp ${order['harga']}' 
                                  : (order['price'] != null ? 'Rp ${order['price']}' : 'Rp 0');

                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(idOrder, style: const TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.w600))),
                                    Expanded(flex: 2, child: Text(namaGame, style: const TextStyle(color: Colors.white70))),
                                    Expanded(flex: 2, child: Text(nominal, style: const TextStyle(color: Colors.white54))),
                                    Expanded(flex: 2, child: Text(hargaStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: statusBackgroundColor(statusStr),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            statusStr, 
                                            style: TextStyle(
                                              color: statusColor(statusStr), 
                                              fontWeight: FontWeight.w700, 
                                              fontSize: 11
                                            )
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 2, child: Container(alignment: Alignment.centerRight, child: Text(waktuStr, style: const TextStyle(color: Colors.white38, fontSize: 11)))),
                                    if (widget.isAdmin)
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                                          onPressed: () {
                                            _showDeleteConfirmation(context, idOrder);
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(child: Text('Muat Lebih Banyak', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(height: 24),
          if (!widget.isAdmin)
            const Text('Hanya admin yang dapat menghapus riwayat pembelian.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  // ✅ FUNGSI KONFIRMASI HAPUS YANG DIPERBAIKI
  void _showDeleteConfirmation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Hapus Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin menghapus transaksi ini?',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: $orderId',
                  style: const TextStyle(
                    color: Color(0xFF818CF8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Data yang dihapus tidak dapat dikembalikan!',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteOrder(orderId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ FUNGSI HAPUS ORDER
  Future<void> _deleteOrder(String orderId) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
      ),
    );

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/riwayat/$orderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Koneksi timeout');
        },
      );

      // Tutup loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Transaksi berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Refresh data
        await fetchRiwayatDariBackend();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal menghapus transaksi: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Tutup loading
      if (context.mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TextStyle _headerStyle() => const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 12);
}
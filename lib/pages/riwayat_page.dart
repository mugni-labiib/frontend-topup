import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<dynamic> transactions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      debugPrint('TOKEN : $token');
      debugPrint('URL : ${ApiConfig.transactions}');

      final response = await http.get(
        Uri.parse(ApiConfig.transactions),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('BODY : ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final dataField = data['data'];
        
        if (dataField is List) {
          setState(() {
            transactions = dataField;
            isLoading = false;
          });
        } else if (dataField is Map) {
          setState(() {
            if (dataField.containsKey('transactions')) {
              transactions = dataField['transactions'] as List? ?? [];
            } else if (dataField.containsKey('data')) {
              transactions = dataField['data'] as List? ?? [];
            } else {
              transactions = dataField.values.toList();
            }
            isLoading = false;
          });
        } else {
          setState(() {
            transactions = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Gagal mengambil riwayat';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ERROR : $e');

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    await fetchTransactions();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'failed':
      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(errorMessage, textAlign: TextAlign.center),
        ),
      );
    }

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat transaksi',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final trx = transactions[index];

          final gameName = trx['game']?['game_name'] ?? 
                           trx['game_name'] ?? 
                           'Game';

          final amount = trx['denomination']?['diamond_amount']?.toString() ?? 
                         trx['diamond_amount']?.toString() ?? 
                         '-';

          final price = trx['total_price']?.toString() ?? 
                        trx['price']?.toString() ?? 
                        '0';

          final status = trx['status'] ?? 'Pending';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gameName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$amount Diamond',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp $price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
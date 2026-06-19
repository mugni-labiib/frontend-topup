import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Get headers with token
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['data']?['token'] != null) {
          await saveToken(data['data']['token']);
        }
      }
      
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  // Get all games
  Future<Map<String, dynamic>> getGames() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.games),
        headers: await getHeaders(),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data game: $e',
      };
    }
  }

  // Get denominations by game
  Future<Map<String, dynamic>> getDenominations(int gameId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.denominations}?game_id=$gameId'),
        headers: await getHeaders(),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil denominasi: $e',
      };
    }
  }

  // Get payment methods
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.payments),
        headers: await getHeaders(),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil metode pembayaran: $e',
      };
    }
  }

  // Create transaction
  Future<Map<String, dynamic>> createTransaction({
    required int denominationId,
    required int paymentMethodId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.transactions),
        headers: await getHeaders(),
        body: json.encode({
          'denomination_id': denominationId,
          'payment_method_id': paymentMethodId,
          'user_id': userId,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat transaksi: $e',
      };
    }
  }

  // Get transaction history
  Future<Map<String, dynamic>> getTransactionHistory() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.transactionHistory),
        headers: await getHeaders(),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil riwayat transaksi: $e',
      };
    }
  }

  // Get dashboard stats (admin)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.adminDashboard),
        headers: await getHeaders(),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data dashboard: $e',
      };
    }
  }

  // Helper to get image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    return '${ApiConfig.uploadsUrl}/$imagePath';
  }
}

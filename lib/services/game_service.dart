import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GameService {
  Future<List<dynamic>> getGames() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/games'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      }

      throw Exception(
        data['message'] ?? 'Gagal mengambil data game',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
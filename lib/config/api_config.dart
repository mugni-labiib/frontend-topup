class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String games = '$baseUrl/games';
  static const String denominations = '$baseUrl/denominations';
  static const String payments = '$baseUrl/payments';
  static const String transactions = '$baseUrl/transactions';
  static const String transactionHistory = '$baseUrl/transactions/history';
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String uploadsUrl = 'http://localhost:3000/uploads';
}
class ApiConfig {
  // Backend API Base URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  
  // Game endpoints
  static const String games = '$baseUrl/games';
  
  // Denomination endpoints
  static const String denominations = '$baseUrl/denominations';
  
  // Payment endpoints
  static const String payments = '$baseUrl/payments';
  
  // Transaction endpoints
  static const String transactions = '$baseUrl/transactions';
  static const String transactionHistory = '$baseUrl/transactions/history';
  
  // Admin endpoints
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  
  // Upload URL
  static const String uploadsUrl = 'http://localhost:3000/uploads';
}

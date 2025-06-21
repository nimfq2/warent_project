import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/whatsapp_number.dart';
import '../models/archive_entry.dart';

class ApiService {
  // Singleton
  ApiService._privateConstructor();
  static final ApiService _instance = ApiService._privateConstructor();
  factory ApiService() {
    return _instance;
  }

  // Приватные поля
  final String _baseUrl = "${dotenv.env['BACKEND_API_URL']}/api/v1";
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Authentication token not found.');
    return {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $token'};
  }

  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed API call with status ${response.statusCode}: ${response.body}');
    }
  }

  // --- AUTHENTICATION ---
  Future<void> logout() async => await _storage.delete(key: 'auth_token');
  
  /// Проверяет одноразовый токен, полученный из URL, и в случае успеха
  /// получает и сохраняет долгоживущий JWT-токен.
  Future<Map<String, dynamic>> validateOneTimeToken(String token) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/validate-token"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'token': token}),
    );
    final data = _parseResponse(response);
    await _storage.write(key: 'auth_token', value: data['access_token']);
    return data;
  }

  // --- USER-FACING API ---
  Future<List<WhatsAppNumber>> getNumbers() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/numbers/"), headers: headers);
    final data = _parseResponse(response) as List;
    return data.map((item) => WhatsAppNumber.fromJson(item)).toList();
  }

  Future<WhatsAppNumber> addNumber(String phoneNumber) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(Uri.parse("$_baseUrl/numbers/"), headers: headers, body: json.encode({'phone_number': phoneNumber}));
    return WhatsAppNumber.fromJson(_parseResponse(response));
  }
  
  Future<void> confirmNumberConnection(int numberId) async {
    final headers = await _getAuthHeaders();
    await http.post(Uri.parse("$_baseUrl/numbers/$numberId/confirm-connection"), headers: headers);
  }

  Future<Map<String, dynamic>> getInfo() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/info/"), headers: headers);
    return _parseResponse(response);
  }

  Future<String?> getWalletAddress() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/users/me"), headers: headers);
    final data = _parseResponse(response);
    return data['crypto_wallet_address'];
  }

  Future<void> updateWalletAddress(String newAddress) async {
    final headers = await _getAuthHeaders();
    await http.post(Uri.parse("$_baseUrl/users/me/wallet"), headers: headers, body: json.encode({'address': newAddress}));
  }

  Future<void> appealForNumber(int numberId) async {
    final headers = await _getAuthHeaders();
    await http.post(Uri.parse("$_baseUrl/numbers/$numberId/appeal"), headers: headers);
  }

  Future<List<ArchiveEntry>> getArchive() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/users/me/archive"), headers: headers);
    final data = _parseResponse(response) as List;
    return data.map((item) => ArchiveEntry.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getReferralInfo() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/users/me/referrals"), headers: headers);
    return _parseResponse(response);
  }

  // --- ADMIN API ---
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/admin/users/"), headers: headers);
    return (_parseResponse(response) as List).cast<Map<String, dynamic>>();
  }
  
  Future<void> sendImageToUser(int numberId, Uint8List imageBytes) async {
    final token = await _storage.read(key: 'auth_token');
    var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/admin/numbers/$numberId/send-image"));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes('image_file', imageBytes, filename: 'code.png'));
    
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to send image with status code ${response.statusCode}');
    }
  }

  Future<Map<String, int>> getAdminDashboardStats() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/admin/dashboard-stats/"), headers: headers);
    return (_parseResponse(response) as Map).cast<String, int>();
  }

  Future<List<WhatsAppNumber>> getAllNumbers() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/admin/numbers/"), headers: headers);
    final data = _parseResponse(response) as List;
    return data.map((item) => WhatsAppNumber.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/admin/users/$userId"), headers: headers);
    return _parseResponse(response);
  }

  Future<List<WhatsAppNumber>> getNumbersForUser(int userId) async {
    final userDetails = await getUserDetails(userId);
    return (userDetails['numbers'] as List).map((n) => WhatsAppNumber.fromJson(n)).toList();
  }
  
  Future<void> updateUserStatus(int userId, bool isActive) async {
    final headers = await _getAuthHeaders();
    await http.patch(Uri.parse("$_baseUrl/admin/users/$userId/status?is_active=$isActive"), headers: headers);
  }

  Future<List<Map<String, String>>> getCryptoBotBalance() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("$_baseUrl/admin/cryptobot-balance/"), headers: headers);
    final data = _parseResponse(response);
    if(data['ok'] == true) {
      return (data['result'] as List).cast<Map<String, String>>();
    } else {
      throw Exception("Failed to get CryptoBot balance: ${data['error']}");
    }
  }

  Future<void> updateInfo(Map<String, dynamic> newInfoData) async {
    final headers = await _getAuthHeaders();
    await http.post(Uri.parse("$_baseUrl/info/"), headers: headers, body: json.encode({"data": newInfoData}));
  }
}
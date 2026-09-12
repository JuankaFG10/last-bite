import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:5000/api';

  // Petición GET
  static Future<http.Response> get(String endpoint) async {
    final token = await StorageService.obtenerToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // Petición POST
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await StorageService.obtenerToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
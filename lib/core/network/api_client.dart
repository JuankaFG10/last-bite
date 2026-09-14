import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiClient {
  // La API de .NET escucha en el puerto 5080 (ver launchSettings.json).
  // Emulador de Android: http://10.0.2.2:5080/api
  // Celular fisico o Web en otra PC: http://<IP-de-la-red>:5080/api
  static const String baseUrl = 'http://localhost:5000/api';//varia segun la maquina donde corre

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
    ).timeout(const Duration(seconds: 10));
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
    ).timeout(const Duration(seconds: 10));
  }
}
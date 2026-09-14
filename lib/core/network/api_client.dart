import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiClient {
  // TODO: cambiar esta IP por la IP de red local de quien levante el backend
  // (Windows: ipconfig / Mac-Linux: ifconfig). "localhost" NO sirve desde el
  // teléfono ni desde el emulador: apunta al propio dispositivo, no a la PC
  // donde corre la API. El backend debe levantarse con:
  //   dotnet run --urls "http://0.0.0.0:5080"
  // y todos (backend y quien pruebe el front) deben estar en la misma wifi.
	static const String baseUrl = 'http://localhost:5080/api';

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
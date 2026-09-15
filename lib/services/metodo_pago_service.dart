import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/metodo_pago_model.dart';

class MetodoPagoService {
  static Future<List<MetodoPago>> listar() async {
    final response = await ApiClient.get('/metodos-pago');

    if (response.statusCode == 200) {
      final List<dynamic> listJson = jsonDecode(response.body);
      final lista = listJson.map((json) => MetodoPago.fromJson(json)).toList();
      lista.sort((a, b) => a.ordenPresentacion.compareTo(b.ordenPresentacion));
      return lista;
    } else {
      throw Exception('No se pudieron obtener los métodos de pago.');
    }
  }
}

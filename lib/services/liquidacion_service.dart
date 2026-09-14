import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/liquidacion_model.dart';

class LiquidacionService {
  // Liquidaciones existentes, opcionalmente filtradas por comercio (endpoint 22)
  static Future<List<Liquidacion>> listar({int? comercioId}) async {
    final query = comercioId != null ? '?comercioId=$comercioId' : '';
    final response = await ApiClient.get('/liquidaciones$query');

    if (response.statusCode == 200) {
      final List<dynamic> listJson = jsonDecode(response.body);
      return listJson.map((json) => Liquidacion.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron obtener las liquidaciones.');
    }
  }

  // Corte con el detalle de cada reserva que entró en él (endpoint 24)
  static Future<LiquidacionDetalle> detalle(int id) async {
    final response = await ApiClient.get('/liquidaciones/$id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LiquidacionDetalle.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Esa liquidación no existe.');
    } else {
      throw Exception('No se pudo obtener el detalle de la liquidación.');
    }
  }
}

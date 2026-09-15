import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/publicacion_model.dart';

class PublicacionService {
  // Bolsas disponibles ahora mismo, opcionalmente filtradas por zona.
  static Future<List<Publicacion>> vigentes({int? zonaId}) async {
    final query = zonaId != null ? '?zonaId=$zonaId' : '';
    final response = await ApiClient.get('/publicaciones$query');

    if (response.statusCode == 200) {
      final List<dynamic> listJson = jsonDecode(response.body);
      return listJson.map((json) => Publicacion.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron obtener las bolsas disponibles.');
    }
  }
}

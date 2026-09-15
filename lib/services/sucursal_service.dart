import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/sucursal_model.dart';
import '../models/asignacion_model.dart';

class SucursalService {
  // Sucursales donde el empleado en sesión está asignado (AsignacionResponse)
  static Future<List<Asignacion>> obtenerMisSucursales() async {
    final response = await ApiClient.get('/mis-sucursales');

    if (response.statusCode == 200) {
      final List<dynamic> listJson = jsonDecode(response.body);
      return listJson.map((json) => Asignacion.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron obtener las sucursales asignadas.');
    }
  }

  // Obtener detalle de una sucursal específica por ID
  static Future<Sucursal> obtenerSucursalPorId(int id) async {
    final response = await ApiClient.get('/sucursales/$id');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Sucursal.fromJson(data);
    } else {
      throw Exception('No se pudo obtener la información de la sucursal.');
    }
  }
}
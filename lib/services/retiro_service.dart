import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/reserva_panel_model.dart';
import '../models/entrega_model.dart';

class RetiroService {
  // Reservas del día en una sucursal (endpoint 19 del contrato)
  static Future<List<ReservaPanel>> reservasDelDia(
    int sucursalId, {
    DateTime? fecha,
  }) async {
    final f = fecha ?? DateTime.now();
    final fechaStr =
        '${f.year.toString().padLeft(4, '0')}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}';

    final response = await ApiClient.get(
      '/sucursales/$sucursalId/reservas?fecha=$fechaStr',
    );

    if (response.statusCode == 200) {
      final List<dynamic> listJson = jsonDecode(response.body);
      return listJson.map((json) => ReservaPanel.fromJson(json)).toList();
    } else {
      throw Exception(_mensajeError(response.body));
    }
  }

  // Validar el código que dicta el cliente y marcar la entrega (endpoint 20)
  static Future<Entrega> retirar(String codigo) async {
    final response = await ApiClient.post('/retiros', {'codigo': codigo});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Entrega.fromJson(data);
    } else {
      throw Exception(_mensajeError(response.body));
    }
  }

  // Traduce el código de error del backend a un mensaje para el usuario.
  static String _mensajeError(String body) {
    try {
      final data = jsonDecode(body);
      final codigo = data['codigo'] ?? '';
      final mensaje = data['mensaje'] ?? 'Ocurrió un error inesperado.';
      switch (codigo) {
        case 'CODIGO_INEXISTENTE':
          return 'Ese código no corresponde a ninguna reserva.';
        case 'RESERVA_NO_ENTREGABLE':
          return 'Esta reserva no se puede entregar: ya fue retirada, está cancelada o no está pagada.';
        case 'EMPLEADO_AJENO':
          return 'No estás asignado a la sucursal de esta reserva.';
        case 'USUARIO_NO_ACTIVO':
          return 'Tu cuenta está suspendida o inactiva.';
        default:
          return mensaje;
      }
    } catch (_) {
      return 'Ocurrió un error inesperado. Verificá tu conexión con el backend.';
    }
  }
}

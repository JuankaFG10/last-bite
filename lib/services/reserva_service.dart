import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/reserva_creada_model.dart';

class ReservaService {
  static Future<ReservaCreada> crear({
    required int publicacionId,
    required int cantidad,
    required int metodoPagoId,
  }) async {
    final response = await ApiClient.post('/reservas', {
      'publicacionId': publicacionId,
      'cantidad': cantidad,
      'metodoPagoId': metodoPagoId,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ReservaCreada.fromJson(data);
    } else {
      throw Exception(_mensajeError(response.body));
    }
  }

  static String _mensajeError(String body) {
    try {
      final data = jsonDecode(body);
      final codigo = data['codigo'] ?? '';
      final mensaje = data['mensaje'] ?? 'Ocurrió un error inesperado.';
      switch (codigo) {
        case 'PUBLICACION_NO_DISPONIBLE':
          return 'Esa bolsa ya no está disponible (se agotó o venció).';
        case 'LIMITE_POR_CLIENTE':
          return 'Ya llegaste al máximo de unidades permitidas para esta bolsa.';
        case 'EFECTIVO_BLOQUEADO':
          return 'Tu cuenta tiene pagos en efectivo bloqueados por faltas anteriores. Elegí otro método de pago.';
        default:
          return mensaje;
      }
    } catch (_) {
      return 'Ocurrió un error inesperado. Verificá tu conexión con el backend.';
    }
  }
}

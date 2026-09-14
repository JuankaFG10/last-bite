/// Corte de pago a un comercio. Coincide con `LiquidacionResponse`
/// (GET /api/liquidaciones).
class Liquidacion {
  final int id;
  final String desde; // "yyyy-MM-dd"
  final String hasta;
  final int reservas;
  final double ventas;
  final double comision;
  final double total;
  final String estado; // CALCULADA · PAGADA · ANULADA

  Liquidacion({
    required this.id,
    required this.desde,
    required this.hasta,
    required this.reservas,
    required this.ventas,
    required this.comision,
    required this.total,
    required this.estado,
  });

  factory Liquidacion.fromJson(Map<String, dynamic> json) {
    return Liquidacion(
      id: json['id'] ?? 0,
      desde: json['desde'] ?? '',
      hasta: json['hasta'] ?? '',
      reservas: json['reservas'] ?? 0,
      ventas: (json['ventas'] ?? 0).toDouble(),
      comision: (json['comision'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
    );
  }
}

/// Una reserva dentro del detalle de una liquidación.
class DetalleLiquidacion {
  final String codigo;
  final String fecha;
  final String bolsa;
  final double monto;

  DetalleLiquidacion({
    required this.codigo,
    required this.fecha,
    required this.bolsa,
    required this.monto,
  });

  factory DetalleLiquidacion.fromJson(Map<String, dynamic> json) {
    return DetalleLiquidacion(
      codigo: json['codigo'] ?? '',
      fecha: json['fecha'] ?? '',
      bolsa: json['bolsa'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
    );
  }
}

/// Coincide con `LiquidacionDetalleResponse`
/// (GET /api/liquidaciones/{id}).
class LiquidacionDetalle {
  final int id;
  final String desde;
  final String hasta;
  final double ventas;
  final double comision;
  final double total;
  final String estado;
  final List<DetalleLiquidacion> detalle;

  LiquidacionDetalle({
    required this.id,
    required this.desde,
    required this.hasta,
    required this.ventas,
    required this.comision,
    required this.total,
    required this.estado,
    required this.detalle,
  });

  factory LiquidacionDetalle.fromJson(Map<String, dynamic> json) {
    final listaJson = json['detalle'] as List<dynamic>? ?? [];
    return LiquidacionDetalle(
      id: json['id'] ?? 0,
      desde: json['desde'] ?? '',
      hasta: json['hasta'] ?? '',
      ventas: (json['ventas'] ?? 0).toDouble(),
      comision: (json['comision'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
      detalle: listaJson.map((e) => DetalleLiquidacion.fromJson(e)).toList(),
    );
  }
}

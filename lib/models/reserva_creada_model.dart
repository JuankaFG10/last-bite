/// Coincide con `ReservaCreadaResponse` (POST /api/reservas).
class ReservaCreada {
  final int reservaId;
  final String codigo;
  final double total;
  final String estado;

  ReservaCreada({
    required this.reservaId,
    required this.codigo,
    required this.total,
    required this.estado,
  });

  factory ReservaCreada.fromJson(Map<String, dynamic> json) {
    return ReservaCreada(
      reservaId: json['reservaId'] ?? 0,
      codigo: json['codigo'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
    );
  }
}

/// Resultado de validar un código de retiro.
/// Coincide con `EntregaResponse` del backend (POST /api/retiros).
class Entrega {
  final int reservaId;
  final String estado;
  final String cliente;
  final String bolsa;
  final int cantidad;

  Entrega({
    required this.reservaId,
    required this.estado,
    required this.cliente,
    required this.bolsa,
    required this.cantidad,
  });

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      reservaId: json['reservaId'] ?? 0,
      estado: json['estado'] ?? '',
      cliente: json['cliente'] ?? '',
      bolsa: json['bolsa'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

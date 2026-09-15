/// Coincide con `MetodoPagoResponse` (GET /api/metodos-pago).
class MetodoPago {
  final int id;
  final String codigo;
  final String nombre;
  final bool requiereConfirmacionEnSitio;
  final int ordenPresentacion;

  MetodoPago({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.requiereConfirmacionEnSitio,
    required this.ordenPresentacion,
  });

  factory MetodoPago.fromJson(Map<String, dynamic> json) {
    return MetodoPago(
      id: json['id'] ?? 0,
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      requiereConfirmacionEnSitio: json['requiereConfirmacionEnSitio'] ?? false,
      ordenPresentacion: json['ordenPresentacion'] ?? 0,
    );
  }
}

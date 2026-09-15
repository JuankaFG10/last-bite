/// Una sucursal donde el empleado en sesión está asignado.
/// Coincide con `AsignacionResponse` del backend real
/// (GET /api/mis-sucursales): { sucursalId, sucursal, cargo }.
class Asignacion {
  final int sucursalId;
  final String sucursal;
  final String cargo;

  Asignacion({
    required this.sucursalId,
    required this.sucursal,
    required this.cargo,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    return Asignacion(
      sucursalId: json['sucursalId'] ?? 0,
      sucursal: json['sucursal'] ?? '',
      cargo: json['cargo'] ?? '',
    );
  }
}

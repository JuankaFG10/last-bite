class Sucursal {
  final int id;
  final int comercioId;
  final String nombre;
  final String direccion;
  final String? telefono;
  final int zonaId;
  final bool activa;

  Sucursal({
    required this.id,
    required this.comercioId,
    required this.nombre,
    required this.direccion,
    this.telefono,
    required this.zonaId,
    this.activa = true,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      // La API devuelve sucursalId y sucursal (SucursalDetalleResponse y
      // AsignacionResponse). Se aceptan los dos nombres por compatibilidad.
      id: json['sucursalId'] ?? json['id'] ?? 0,
      comercioId: json['comercioId'] ?? 0,
      nombre: json['sucursal'] ?? json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'],
      zonaId: json['zonaId'] ?? 0,
      activa: json['activa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comercioId': comercioId,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'zonaId': zonaId,
      'activa': activa,
    };
  }
}
class Zona {
  final int id;
  final String nombre;
  final bool activa;

  Zona({
    required this.id,
    required this.nombre,
    this.activa = true,
  });

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      activa: json['activa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'activa': activa,
    };
  }
}
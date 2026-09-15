/// Una bolsa disponible para reservar ahora mismo.
/// Coincide con `PublicacionResponse` (GET /api/publicaciones).
class Publicacion {
  final int publicacionId;
  final String bolsa;
  final String tipoAlimento;
  final double precioVenta;
  final double valorEstimado;
  final int descuentoPct;
  final int cantidadDisponible;
  final String fecha; // "yyyy-MM-dd"
  final String horaInicioRetiro; // "HH:mm:ss"
  final String horaFinRetiro;
  final int sucursalId;
  final String sucursal;
  final String nombreComercial;
  final String rubro;
  final int zonaId;
  final String zona;

  Publicacion({
    required this.publicacionId,
    required this.bolsa,
    required this.tipoAlimento,
    required this.precioVenta,
    required this.valorEstimado,
    required this.descuentoPct,
    required this.cantidadDisponible,
    required this.fecha,
    required this.horaInicioRetiro,
    required this.horaFinRetiro,
    required this.sucursalId,
    required this.sucursal,
    required this.nombreComercial,
    required this.rubro,
    required this.zonaId,
    required this.zona,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    return Publicacion(
      publicacionId: json['publicacionId'] ?? 0,
      bolsa: json['bolsa'] ?? '',
      tipoAlimento: json['tipoAlimento'] ?? '',
      precioVenta: (json['precioVenta'] ?? 0).toDouble(),
      valorEstimado: (json['valorEstimado'] ?? 0).toDouble(),
      descuentoPct: json['descuentoPct'] ?? 0,
      cantidadDisponible: json['cantidadDisponible'] ?? 0,
      fecha: json['fecha'] ?? '',
      horaInicioRetiro: json['horaInicioRetiro'] ?? '',
      horaFinRetiro: json['horaFinRetiro'] ?? '',
      sucursalId: json['sucursalId'] ?? 0,
      sucursal: json['sucursal'] ?? '',
      nombreComercial: json['nombreComercial'] ?? '',
      rubro: json['rubro'] ?? '',
      zonaId: json['zonaId'] ?? 0,
      zona: json['zona'] ?? '',
    );
  }

  /// "18:30:00" -> "6:30 PM"
  static String horaCorta(String horaIso) {
    if (horaIso.isEmpty) return '--';
    final partes = horaIso.split(':');
    if (partes.length < 2) return horaIso;
    var h = int.tryParse(partes[0]) ?? 0;
    final m = partes[1];
    final sufijo = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return '$h:$m $sufijo';
  }
}

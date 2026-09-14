/// Fila de la pantalla "Reservas del día" del panel.
/// Coincide con `ReservaPanelResponse` del backend (endpoint
/// GET /api/sucursales/{id}/reservas).
class ReservaPanel {
  final int reservaId;
  final String codigo;
  final String cliente;
  final String? clienteTelefono;
  final String bolsa;
  final int cantidad;
  final double total;
  final String estadoReserva; // PENDIENTE_PAGO · CONFIRMADA · RETIRADA · NO_RETIRADA · CANCELADA · REEMBOLSADA
  final String? estadoPago;
  final String horaInicioRetiro; // "HH:mm:ss"
  final String horaFinRetiro;
  final DateTime? retiroDate;
  final String? entregadoPor;

  ReservaPanel({
    required this.reservaId,
    required this.codigo,
    required this.cliente,
    this.clienteTelefono,
    required this.bolsa,
    required this.cantidad,
    required this.total,
    required this.estadoReserva,
    this.estadoPago,
    required this.horaInicioRetiro,
    required this.horaFinRetiro,
    this.retiroDate,
    this.entregadoPor,
  });

  factory ReservaPanel.fromJson(Map<String, dynamic> json) {
    return ReservaPanel(
      reservaId: json['reservaId'] ?? 0,
      codigo: json['codigo'] ?? '',
      cliente: json['cliente'] ?? '',
      clienteTelefono: json['clienteTelefono'],
      bolsa: json['bolsa'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      estadoReserva: json['estadoReserva'] ?? '',
      estadoPago: json['estadoPago'],
      horaInicioRetiro: json['horaInicioRetiro'] ?? '',
      horaFinRetiro: json['horaFinRetiro'] ?? '',
      retiroDate: json['retiroDate'] != null
          ? DateTime.tryParse(json['retiroDate'])
          : null,
      entregadoPor: json['entregadoPor'],
    );
  }

  /// "14:30:00" -> "2:30 PM". Tolerante a formatos con segundos u offset.
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

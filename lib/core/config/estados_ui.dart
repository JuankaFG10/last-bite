import 'package:flutter/material.dart';
import 'theme.dart';

/// Color y etiqueta para pintar los estados que vienen del backend
/// (en_estado_reserva, en_estado_pago, estado de liquidación).
class EstadoUi {
  final Color color;
  final Color fondo;
  final String etiqueta;

  const EstadoUi(this.color, this.fondo, this.etiqueta);

  static EstadoUi deReserva(String estado) {
    switch (estado) {
      case 'CONFIRMADA':
        return const EstadoUi(Color(0xFF3D86C7), Color(0xFFE7F1FA), 'Confirmada');
      case 'RETIRADA':
        return const EstadoUi(AppTheme.primary, AppTheme.badgeTagBackground, 'Retirada');
      case 'PENDIENTE_PAGO':
        return const EstadoUi(Color(0xFFD4791F), Color(0xFFFBF0E3), 'Pendiente de pago');
      case 'NO_RETIRADA':
        return const EstadoUi(Color(0xFFE28379), Color(0xFFFBEAE8), 'No retirada');
      case 'CANCELADA':
        return const EstadoUi(AppTheme.textMuted, Color(0xFFEFEFEF), 'Cancelada');
      case 'REEMBOLSADA':
        return const EstadoUi(AppTheme.textMuted, Color(0xFFEFEFEF), 'Reembolsada');
      default:
        return EstadoUi(AppTheme.textMuted, const Color(0xFFEFEFEF), estado);
    }
  }

  static EstadoUi deLiquidacion(String estado) {
    switch (estado) {
      case 'CALCULADA':
        return const EstadoUi(Color(0xFFD4791F), Color(0xFFFBF0E3), 'Calculada');
      case 'PAGADA':
        return const EstadoUi(AppTheme.primary, AppTheme.badgeTagBackground, 'Pagada');
      case 'ANULADA':
        return const EstadoUi(Color(0xFFE28379), Color(0xFFFBEAE8), 'Anulada');
      default:
        return EstadoUi(AppTheme.textMuted, const Color(0xFFEFEFEF), estado);
    }
  }
}

/// Pastilla pequeña con el estado, lista para usar en listas y detalles.
class EstadoBadge extends StatelessWidget {
  final EstadoUi estado;
  const EstadoBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: estado.fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(
          color: estado.color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

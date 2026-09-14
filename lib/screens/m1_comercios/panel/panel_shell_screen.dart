import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';
import '../../m4_retiro/reservas_del_dia_screen.dart';
import '../../m4_retiro/entregar_retiro_screen.dart';
import '../../m6_liquidacion/liquidaciones_screen.dart';

/// Contenedor del panel del comercio: agrupa Reservas del día, Entregar y
/// Liquidaciones en una barra inferior, para no repetir el login por pantalla.
class PanelShellScreen extends StatefulWidget {
  final int sucursalId;
  const PanelShellScreen({super.key, required this.sucursalId});

  @override
  State<PanelShellScreen> createState() => _PanelShellScreenState();
}

class _PanelShellScreenState extends State<PanelShellScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      ReservasDelDiaScreen(sucursalId: widget.sucursalId),
      const EntregarRetiroScreen(),
      const LiquidacionesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pantallas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Entregar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Liquidaciones',
          ),
        ],
      ),
    );
  }
}

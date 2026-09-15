import 'package:flutter/material.dart';
import 'core/config/theme.dart';
import 'screens/m0_auth/apertura_screen.dart';
import 'screens/m0_auth/bienvenida_screen.dart';
import 'screens/m0_auth/login_screen.dart';
import 'screens/m0_auth/registro_screen.dart';
import 'screens/m0_auth/perfil_cliente_screen.dart';
import 'screens/m0_auth/modo_prueba_screen.dart';
import 'screens/m2_oferta/explorar_screen.dart';
import 'screens/m1_comercios/panel/elegir_sucursal_screen.dart';
import 'screens/m1_comercios/panel/panel_shell_screen.dart';
import 'screens/m1_comercios/cliente/detalle_sucursal_screen.dart';
import 'screens/admin/admin_crear_usuario_screen.dart';
import 'screens/admin/admin_roles_accesos_screen.dart';

void main() {
  runApp(const LastBiteApp());
}

class LastBiteApp extends StatelessWidget {
  const LastBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Last Bite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        // ── M0 · Auth ──────────────────────────────────────────────────
        '/':               (context) => const AperturaScreen(),
        '/bienvenida':     (context) => const BienvenidaScreen(),
        '/login':          (context) => const LoginScreen(),
        '/registro':       (context) => const RegistroScreen(),
        '/perfil-cliente': (context) => const PerfilClienteScreen(),
        '/modo-prueba':    (context) => const ModoPruebaScreen(), // TODO: quitar cuando exista el login real
        '/explorar':       (context) => const ExplorarScreen(),

        // ── M1 · Comercios ─────────────────────────────────────────────
        '/elegir-sucursal':   (context) => const ElegirSucursalScreen(),
        '/detalle-sucursal':  (context) => const DetalleSucursalScreen(),

        // ── Admin ──────────────────────────────────────────────────────
        '/admin-crear-usuario': (context) => const AdminCrearUsuarioScreen(),
        '/admin-roles':         (context) => const AdminRolesAccesosScreen(),

        // ── M4/M6 · Panel (reservas del día, entregar, liquidaciones) ───
        '/reservas-del-dia': (context) {
          final sucursalId = ModalRoute.of(context)!.settings.arguments as int;
          return PanelShellScreen(sucursalId: sucursalId);
        },
      },
    );
  }
}

/// Placeholder mientras se construye la pantalla correspondiente.
class _Placeholder extends StatelessWidget {
  final String titulo;
  const _Placeholder({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded,
                size: 48, color: AppTheme.primary),
            const SizedBox(height: 12),
            Text(titulo, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            const Text(
              'En construcción',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
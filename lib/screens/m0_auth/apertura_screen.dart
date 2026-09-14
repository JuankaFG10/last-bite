import 'package:flutter/material.dart';
import '../../core/network/storage_service.dart';
import '../../models/usuario_model.dart';

class AperturaScreen extends StatefulWidget {
  const AperturaScreen({super.key});

  @override
  State<AperturaScreen> createState() => _AperturaScreenState();
}

class _AperturaScreenState extends State<AperturaScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final token = await StorageService.obtenerToken();
    final usuario = await StorageService.obtenerUsuario();

    if (!mounted) return;

    if (token == null || usuario == null) {
      // Sin sesión activa -> ir a Bienvenida/Login
      Navigator.pushReplacementNamed(context, '/bienvenida');
      return;
    }

    // Redirección basada en roles
    _redirigirPorRol(usuario);
  }

  void _redirigirPorRol(Usuario usuario) {
    if (usuario.roles.contains('ADMIN')) {
      Navigator.pushReplacementNamed(context, '/admin-roles');
    } else if (usuario.roles.contains('COMERCIO')) {
      Navigator.pushReplacementNamed(context, '/elegir-sucursal');
    } else {
      Navigator.pushReplacementNamed(context, '/perfil-cliente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
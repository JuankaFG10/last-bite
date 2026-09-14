import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/network/storage_service.dart';

/// SOLO PARA DESARROLLO. Mientras el AuthController real no exista, esta
/// pantalla deja pegar un JWT generado a mano (jwt.io) y un sucursalId,
/// para poder ver y probar el panel (reservas del día / entregar /
/// liquidaciones) sin depender del login.
///
/// Se llega escribiendo la ruta directamente en la barra del navegador
/// cuando se corre con `flutter run -d chrome`:  .../#/modo-prueba
/// Borrar esta pantalla y su ruta en main.dart cuando el login real exista.
class ModoPruebaScreen extends StatefulWidget {
  const ModoPruebaScreen({super.key});

  @override
  State<ModoPruebaScreen> createState() => _ModoPruebaScreenState();
}

class _ModoPruebaScreenState extends State<ModoPruebaScreen> {
  final _tokenController = TextEditingController();
  final _sucursalController = TextEditingController(text: '5');

  @override
  void dispose() {
    _tokenController.dispose();
    _sucursalController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final token = _tokenController.text.trim();
    final sucursalId = int.tryParse(_sucursalController.text.trim());

    if (token.isEmpty || sucursalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pegá el token y un ID de sucursal válido.')),
      );
      return;
    }

    await StorageService.guardarToken(token);
    await StorageService.guardarSucursalId(sucursalId);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/reservas-del-dia', arguments: sucursalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Modo prueba (dev)'),
        backgroundColor: Colors.amber.shade50,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Text(
                  'Esta pantalla no llama al backend de login: solo guarda un '
                  'token que vos generás a mano (jwt.io) para poder ver las '
                  'pantallas del panel mientras el AuthController real no existe.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _tokenController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'JWT (Bearer token)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sucursalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID de sucursal'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _entrar,
                child: const Text('Guardar y entrar al panel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

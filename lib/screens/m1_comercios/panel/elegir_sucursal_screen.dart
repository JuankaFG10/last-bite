import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';
import '../../../core/network/storage_service.dart';
import '../../../models/asignacion_model.dart';
import '../../../services/sucursal_service.dart';

class ElegirSucursalScreen extends StatefulWidget {
  const ElegirSucursalScreen({super.key});

  @override
  State<ElegirSucursalScreen> createState() => _ElegirSucursalScreenState();
}

class _ElegirSucursalScreenState extends State<ElegirSucursalScreen> {
  List<Asignacion>? _sucursales;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarSucursales();
  }

  // Sucursales demo para visualizar sin backend
  static final List<Asignacion> _sucursalesDemo = [
    Asignacion(sucursalId: 5, sucursal: 'El Trigal · Centro', cargo: 'ENCARGADO'),
    Asignacion(sucursalId: 6, sucursal: 'El Trigal · Circunvalación', cargo: 'CAJERO'),
  ];

  Future<void> _cargarSucursales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lista = await SucursalService.obtenerMisSucursales();

      if (!mounted) return;

      // Si solo hay una sucursal asignada → seleccionar automáticamente
      if (lista.length == 1) {
        await _seleccionar(lista.first, silencioso: true);
        return;
      }

      setState(() {
        _sucursales = lista;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      // En modo demo, cargamos datos de ejemplo
      final token = await StorageService.obtenerToken();
      if (token == 'demo-token-fake') {
        setState(() {
          _sucursales = _sucursalesDemo;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _error = 'No se pudieron obtener las sucursales asignadas.';
        _isLoading = false;
      });
    }
  }

  Future<void> _seleccionar(Asignacion asignacion, {bool silencioso = false}) async {
    await StorageService.guardarSucursalId(asignacion.sucursalId);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/reservas-del-dia',
      arguments: asignacion.sucursalId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cargarSucursales,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final sucursales = _sucursales ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Encabezado ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Dónde estás hoy?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Elegí la sucursal donde vas a trabajar',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // ── Lista de sucursales ─────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: sucursales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final asignacion = sucursales[i];
              return _SucursalTile(
                asignacion: asignacion,
                onTap: () => _seleccionar(asignacion),
              );
            },
          ),
        ),

        // ── Nota de pie ─────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppTheme.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Solo podés entregar bolsas en la sucursal donde estás asignado.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tile de sucursal ──────────────────────────────────────────────────────────

class _SucursalTile extends StatelessWidget {
  final Asignacion asignacion;
  final VoidCallback onTap;

  const _SucursalTile({required this.asignacion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Iniciales del nombre de la sucursal para el avatar
    final palabras = asignacion.sucursal.trim().split(' ');
    final iniciales = palabras.length >= 2
        ? '${palabras[0][0]}${palabras[1][0]}'.toUpperCase()
        : (asignacion.sucursal.isEmpty
            ? '--'
            : asignacion.sucursal.substring(0, asignacion.sucursal.length.clamp(0, 2)).toUpperCase());

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            iniciales,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          asignacion.sucursal,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          asignacion.cargo,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}

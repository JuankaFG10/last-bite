import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';
import '../../../core/network/storage_service.dart';
import '../../../models/sucursal_model.dart';
import '../../../services/sucursal_service.dart';

class DetalleSucursalScreen extends StatefulWidget {
  const DetalleSucursalScreen({super.key});

  @override
  State<DetalleSucursalScreen> createState() => _DetalleSucursalScreenState();
}

class _DetalleSucursalScreenState extends State<DetalleSucursalScreen> {
  Sucursal? _sucursal;
  bool _isLoading = true;
  String? _error;
  int? _sucursalId;

  // Demo sucursales (mismo map que elegir_sucursal)
  static final Map<int, Sucursal> _demoMap = {
    5: Sucursal(id: 5, comercioId: 1, nombre: 'El Trigal · Centro',
        direccion: 'Colonia Trejo, SPS', telefono: '+504 2550 1122',
        zonaId: 1, activa: true),
    6: Sucursal(id: 6, comercioId: 1, nombre: 'El Trigal · Circunvalación',
        direccion: 'Av. Circunvalación, SPS', telefono: '+504 2550 3344',
        zonaId: 2, activa: true),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _sucursalId == null) {
      _sucursalId = args;
      _cargarSucursal();
    }
  }

  Future<void> _cargarSucursal() async {
    try {
      final suc = await SucursalService.obtenerSucursalPorId(_sucursalId!);
      if (mounted) setState(() { _sucursal = suc; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      // Modo demo
      final token = await StorageService.obtenerToken();
      if (token == 'demo-token-fake' && _demoMap.containsKey(_sucursalId)) {
        setState(() { _sucursal = _demoMap[_sucursalId]; _isLoading = false; });
      } else {
        setState(() {
          _error = 'No se pudo cargar la sucursal.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sucursalId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sucursal')),
        body: const Center(child: Text('ID de sucursal no recibido.')),
      );
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sucursal')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.textMuted),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () { setState(() { _isLoading = true; _error = null; }); _cargarSucursal(); },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildVista(_sucursal!);
  }

  Widget _buildVista(Sucursal suc) {
    final palabras = suc.nombre.trim().split(' ');
    final iniciales = palabras.length >= 2
        ? '${palabras[0][0]}${palabras[1][0]}'.toUpperCase()
        : suc.nombre.substring(0, 2).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      appBar: AppBar(
        title: Text(suc.nombre),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header card ──────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryLight,
                    child: Text(
                      iniciales,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(suc.nombre,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  const Text('Panadería y repostería',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: suc.activa ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      suc.activa ? '🟢 Abierto ahora' : '⚫ Cerrado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: suc.activa ? const Color(0xFF1B5E20) : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Información ─────────────────────────────────────────────
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 20),
                  title: Text(suc.direccion, style: Theme.of(context).textTheme.bodyLarge),
                  dense: true,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 20),
                  title: const Text('Retiros hasta las 8:30 PM',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  subtitle: const Text('Hora límite de la zona',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  dense: true,
                ),
                if (suc.telefono != null) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppTheme.primary, size: 20),
                    title: Text(suc.telefono!,
                        style: Theme.of(context).textTheme.bodyLarge),
                    dense: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Bolsas de hoy ───────────────────────────────────────────
          Text('Bolsas de hoy',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _BolsaCard(
            iniciales: iniciales,
            nombre: 'Bolsa de panadería',
            horario: 'Retiro 6:00 – 8:00 PM',
            unidades: 3,
            precioOriginal: 180,
            precioRescate: 65,
          ),
          const SizedBox(height: 8),
          _BolsaCard(
            iniciales: iniciales,
            nombre: 'Bolsa sorpresa',
            horario: 'Retiro 5:00 – 7:00 PM',
            unidades: 1,
            precioOriginal: 250,
            precioRescate: 90,
          ),
        ],
      ),
    );
  }
}

// ── Bolsa card ──────────────────────────────────────────────────────────────

class _BolsaCard extends StatelessWidget {
  final String iniciales;
  final String nombre;
  final String horario;
  final int unidades;
  final double precioOriginal;
  final double precioRescate;

  const _BolsaCard({
    required this.iniciales,
    required this.nombre,
    required this.horario,
    required this.unidades,
    required this.precioOriginal,
    required this.precioRescate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryLight,
              child: Text(iniciales,
                  style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(horario,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.badgeTagBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Quedan $unidades ${unidades == 1 ? 'bolsa' : 'bolsas'}',
                      style: const TextStyle(
                        fontSize: 11, color: AppTheme.badgeTagText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('L ${precioOriginal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textStrike,
                        decoration: TextDecoration.lineThrough)),
                Text('L ${precioRescate.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: AppTheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

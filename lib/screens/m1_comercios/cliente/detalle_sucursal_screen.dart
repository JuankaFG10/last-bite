import 'package:flutter/material.dart';
import '../../../core/config/theme.dart';
import '../../../models/sucursal_model.dart';
import '../../../services/sucursal_service.dart';

class DetalleSucursalScreen extends StatefulWidget {
  const DetalleSucursalScreen({super.key});

  @override
  State<DetalleSucursalScreen> createState() => _DetalleSucursalScreenState();
}

class _DetalleSucursalScreenState extends State<DetalleSucursalScreen> {
  late Future<Sucursal> _futuro;
  int? _sucursalId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // El ID llega como argumento de ruta
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _sucursalId == null) {
      _sucursalId = args;
      _futuro = SucursalService.obtenerSucursalPorId(_sucursalId!);
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

    return FutureBuilder<Sucursal>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sucursal')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 48, color: AppTheme.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      snap.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _futuro = SucursalService.obtenerSucursalPorId(_sucursalId!);
                      }),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final suc = snap.data!;
        return _buildVista(suc);
      },
    );
  }

  Widget _buildVista(Sucursal suc) {
    // Iniciales para avatar
    final palabras = suc.nombre.trim().split(' ');
    final iniciales = palabras.length >= 2
        ? '${palabras[0][0]}${palabras[1][0]}'.toUpperCase()
        : suc.nombre.substring(0, 2).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: CustomScrollView(
        slivers: [
          // ── AppBar deslizable con info de la sucursal ─────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar con iniciales
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        iniciales,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suc.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Estado activo
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: suc.activa
                                  ? Colors.green.shade400
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              suc.activa ? 'Abierto ahora' : 'Cerrado',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info rápida
                  _InfoCard(
                    children: [
                      _InfoFila(
                        icon: Icons.location_on_outlined,
                        label: suc.direccion,
                      ),
                      const Divider(height: 1),
                      if (suc.telefono != null)
                        _InfoFila(
                          icon: Icons.phone_outlined,
                          label: suc.telefono!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nota de hora límite (viene de la zona — dato futuro del backend)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 18, color: AppTheme.primary),
                        SizedBox(width: 10),
                        Text(
                          'Hora límite de retiro según zona',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sección bolsas del día — card de ejemplo (datos reales via API)
                  Text(
                    'Bolsas de hoy',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  _BolsaCard(
                    iniciales: 'ET',
                    nombre: 'Bolsa sorpresa',
                    horario: 'Retiro 6:00 – 8:00 PM',
                    unidades: 3,
                    precioOriginal: 180,
                    precioRescate: 65,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoFila({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 20),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

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
            // Avatar iniciales del comercio
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                iniciales,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Datos de la bolsa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    horario,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.badgeTagBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Quedan $unidades bolsas',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.badgeTagText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Precios
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'L ${precioOriginal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textStrike,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  'L ${precioRescate.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

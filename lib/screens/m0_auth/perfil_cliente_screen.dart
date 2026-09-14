import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/network/storage_service.dart';
import '../../models/usuario_model.dart';
import '../../services/auth_service.dart';
import '../../services/local_preferences_service.dart';

class PerfilClienteScreen extends StatefulWidget {
  const PerfilClienteScreen({super.key});

  @override
  State<PerfilClienteScreen> createState() => _PerfilClienteScreenState();
}

class _PerfilClienteScreenState extends State<PerfilClienteScreen> {
  Usuario? _usuario;
  String? _zonaNombre;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      // Intenta refrescar desde la API; si falla, usa caché local
      final usuario = await AuthService.obtenerPerfilActual();
      final zona = await LocalPreferencesService.obtenerZonaPreferidaNombre();
      if (mounted) {
        setState(() {
          _usuario = usuario;
          _zonaNombre = zona;
          _isLoading = false;
        });
      }
    } catch (_) {
      final usuarioLocal = await StorageService.obtenerUsuario();
      final zona = await LocalPreferencesService.obtenerZonaPreferidaNombre();
      if (mounted) {
        setState(() {
          _usuario = usuarioLocal;
          _zonaNombre = zona;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que querés salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/bienvenida');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_usuario == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo cargar el perfil.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/bienvenida'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      );
    }

    final usuario = _usuario!;
    final initiales = _iniciales(usuario.nombres, usuario.apellidos);
    final tieneBloqueo = usuario.noShows >= 3;

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarPerfil,
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            // ── Avatar + nombre ──────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      initiales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${usuario.nombres} ${usuario.apellidos}',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.correo,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // ── Contador de faltas ─────────────────────────────────
                  _NoShowsBanner(
                    noShows: usuario.noShows,
                    tieneBloqueo: tieneBloqueo,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Sección: mis reservas ────────────────────────────────────
            _SeccionTitulo('Mis reservas'),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Text('Reservas activas',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '0',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 36, color: AppTheme.textMuted),
                          const SizedBox(height: 8),
                          const Text(
                            'No tenés reservas activas',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Cuando reserves una bolsa aparecerá aquí.',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('Ver historial completo'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Sección: datos personales ────────────────────────────────
            _SeccionTitulo('Datos personales'),
            _TileInfo(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              sublabel: usuario.telefono ?? 'No disponible en este perfil',
            ),
            _TileInfo(
              icon: Icons.location_on_outlined,
              label: 'Zona preferida',
              sublabel: _zonaNombre ?? 'Sin zona seleccionada',
            ),

            const SizedBox(height: 28),

            // ── Cerrar sesión ─────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
      // ── Bottom nav ──────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            // TODO: /inicio-cliente
          } else if (i == 1) {
            // TODO: /mis-reservas
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  String _iniciales(String nombres, String apellidos) {
    final n = nombres.isNotEmpty ? nombres[0].toUpperCase() : '';
    final a = apellidos.isNotEmpty ? apellidos[0].toUpperCase() : '';
    return '$n$a';
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _NoShowsBanner extends StatelessWidget {
  final int noShows;
  final bool tieneBloqueo;

  const _NoShowsBanner({required this.noShows, required this.tieneBloqueo});

  @override
  Widget build(BuildContext context) {
    final color = tieneBloqueo ? Colors.red.shade50 : AppTheme.primaryLight;
    final borderColor = tieneBloqueo ? Colors.red.shade200 : AppTheme.accentMint;
    final iconColor = tieneBloqueo ? Colors.redAccent : AppTheme.primary;
    final texto = tieneBloqueo
        ? 'Con 3 faltas se desactiva el pago en efectivo. Retirá tus bolsas a tiempo.'
        : 'Con 3 faltas se desactiva el pago en efectivo.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            tieneBloqueo ? Icons.warning_amber_rounded : Icons.info_outline,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$noShows ${noShows == 1 ? 'falta acumulada' : 'faltas acumuladas'}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _TileInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _TileInfo({
    required this.icon,
    required this.label,
    this.sublabel,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 22),
        title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: sublabel != null
            ? Text(sublabel!, style: Theme.of(context).textTheme.bodyMedium)
            : null,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
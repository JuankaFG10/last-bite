import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/network/storage_service.dart';
import '../../models/usuario_model.dart';
import '../../models/zona_model.dart';
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
  int _navIndex = 2; // Perfil activo

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
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

  // ── Diálogo para seleccionar zona preferida ─────────────────────────────
  Future<void> _seleccionarZona() async {
    // Zonas demo — en producción vendrían de GET /zonas
    final zonas = [
      Zona(id: 1, nombre: 'Centro', activa: true),
      Zona(id: 2, nombre: 'Circunvalación', activa: true),
      Zona(id: 3, nombre: 'Los Castaños', activa: true),
      Zona(id: 4, nombre: 'Villas del Sol', activa: true),
    ];

    final seleccion = await showModalBottomSheet<Zona>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Zona preferida',
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Elegí la zona donde preferís recoger tus bolsas.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ...zonas.map((z) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(ctx, z),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: z.nombre == _zonaNombre
                        ? AppTheme.primaryLight
                        : AppTheme.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: z.nombre == _zonaNombre
                          ? AppTheme.primary
                          : AppTheme.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: z.nombre == _zonaNombre
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        z.nombre,
                        style: TextStyle(
                          fontWeight: z.nombre == _zonaNombre
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (z.nombre == _zonaNombre)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primary, size: 20),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );

    if (seleccion != null) {
      await LocalPreferencesService.guardarZonaPreferida(
        id: seleccion.id,
        nombre: seleccion.nombre,
      );
      if (mounted) {
        setState(() => _zonaNombre = seleccion.nombre);
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
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
                  // Avatar con opción de tocar (futuro: cambiar foto)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La foto de perfil estará disponible cuando se conecte el almacenamiento.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Stack(
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
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentMint,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 12, color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
            _SeccionTitulo('MIS RESERVAS'),
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
                      child: const Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 36, color: AppTheme.textMuted),
                          SizedBox(height: 8),
                          Text(
                            'No tenés reservas activas',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
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
            _SeccionTitulo('DATOS PERSONALES'),
            _TileInfo(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              sublabel: usuario.correo, // en demo, muestra el correo como referencia
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El teléfono se podrá editar cuando se conecte el endpoint PUT /perfil.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _TileInfo(
              icon: Icons.location_on_outlined,
              label: 'Zona preferida',
              sublabel: _zonaNombre ?? 'Sin zona — toca para elegir',
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
              onTap: _seleccionarZona,
            ),

            const SizedBox(height: 28),

            // ── Cerrar sesión ─────────────────────────────────────────────
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // ── Bottom nav ──────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == _navIndex) return;
          setState(() => _navIndex = i);
          // Los tabs de Inicio y Reservas no están asignados a este dev,
          // pero navegan para no quedar rotos
          if (i == 0 || i == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  i == 0
                      ? 'Pantalla de Inicio pendiente de otro módulo.'
                      : 'Pantalla de Reservas pendiente de otro módulo.',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            // Volvemos a Perfil
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) setState(() => _navIndex = 2);
            });
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

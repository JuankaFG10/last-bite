import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/network/storage_service.dart';
import '../../models/usuario_model.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  // ── Modo demo: inyecta un usuario falso y navega sin backend ─────────────
  Future<void> _entrarDemo(BuildContext context, String rol) async {
    final usuario = Usuario(
      id: 999,
      nombres: 'Demo',
      apellidos: rol == 'ADMIN' ? 'Admin' : rol == 'COMERCIO' ? 'Empleado' : 'Cliente',
      correo: 'demo@lastbite.hn',
      roles: [rol],
      noShows: rol == 'CLIENTE' ? 1 : 0,
    );
    await StorageService.guardarToken('demo-token-fake');
    await StorageService.guardarUsuario(usuario);

    if (!context.mounted) return;

    if (rol == 'ADMIN') {
      Navigator.pushReplacementNamed(context, '/admin-roles');
    } else if (rol == 'COMERCIO') {
      Navigator.pushReplacementNamed(context, '/elegir-sucursal');
    } else {
      Navigator.pushReplacementNamed(context, '/perfil-cliente');
    }
  }

  void _mostrarMenuDemo(BuildContext context) {
    showModalBottomSheet(
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
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              '🔧 Modo demo',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Entrá sin backend como un rol específico.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            _DemoRolTile(
              emoji: '👤',
              label: 'Cliente',
              sublabel: 'Ver perfil, reservas y zonas',
              color: const Color(0xFFE8F5E9),
              onTap: () { Navigator.pop(ctx); _entrarDemo(context, 'CLIENTE'); },
            ),
            const SizedBox(height: 10),
            _DemoRolTile(
              emoji: '🏪',
              label: 'Comercio / Empleado',
              sublabel: 'Selección de sucursal y panel',
              color: AppTheme.primaryLight,
              onTap: () { Navigator.pop(ctx); _entrarDemo(context, 'COMERCIO'); },
            ),
            const SizedBox(height: 10),
            _DemoRolTile(
              emoji: '🛡️',
              label: 'Administrador',
              sublabel: 'Gestión de usuarios y roles',
              color: const Color(0xFFFFF3E0),
              onTap: () { Navigator.pop(ctx); _entrarDemo(context, 'ADMIN'); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Sección superior: ilustración + branding ──────────────────
            Expanded(
              flex: 5,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Círculos decorativos de fondo
                  Positioned(
                    right: -50,
                    top: -30,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -40,
                    bottom: 60,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lunch_dining_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Last Bite',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Ilustración central ───────────────────────────
                        Expanded(
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Halo exterior
                                Container(
                                  width: 190,
                                  height: 190,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                // Círculo principal
                                Container(
                                  width: 148,
                                  height: 148,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.14),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_rounded,
                                    size: 72,
                                    color: Colors.white,
                                  ),
                                ),

                                // Badge: pizza
                                Positioned(
                                  top: 2,
                                  right: -4,
                                  child: _FoodBadge(
                                    icon: Icons.local_pizza_outlined,
                                    bg: AppTheme.accentMint,
                                  ),
                                ),
                                // Badge: croissant
                                Positioned(
                                  bottom: 10,
                                  left: -8,
                                  child: _FoodBadge(
                                    icon: Icons.bakery_dining_rounded,
                                    bg: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                // Badge: ensalada
                                Positioned(
                                  top: 20,
                                  left: -16,
                                  child: _FoodBadge(
                                    icon: Icons.eco_rounded,
                                    bg: Colors.white.withValues(alpha: 0.18),
                                    small: true,
                                  ),
                                ),
                                // Badge: precio
                                Positioned(
                                  bottom: 4,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '- 60 %',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tagline
                        const Text(
                          'Rescatá comida\nbuena antes de\nque se pierda.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Sección inferior: card blanca con CTAs ────────────────────
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.backgroundMain,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Comida buena, precio justo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comercios de San Pedro Sula publican lo que les sobró del día. Vos lo rescatás.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/registro'),
                    child: const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Ya tengo cuenta'),
                  ),
                  const SizedBox(height: 14),

                  // ── Acceso demo ─────────────────────────────────────────
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _mostrarMenuDemo(context),
                      icon: const Icon(Icons.science_outlined, size: 16),
                      label: const Text('Modo demo'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _FoodBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final bool small;

  const _FoodBadge({required this.icon, required this.bg, this.small = false});

  @override
  Widget build(BuildContext context) {
    final size = small ? 28.0 : 36.0;
    final iconSize = small ? 15.0 : 19.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }
}

class _DemoRolTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _DemoRolTile({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/config/theme.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

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

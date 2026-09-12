import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/network/api_client.dart';
import '../../services/auth_service.dart';

class AdminRolesAccesosScreen extends StatefulWidget {
  const AdminRolesAccesosScreen({super.key});

  @override
  State<AdminRolesAccesosScreen> createState() =>
      _AdminRolesAccesosScreenState();
}

class _AdminRolesAccesosScreenState extends State<AdminRolesAccesosScreen> {
  bool _isLoading = false;

  // Datos demo — en producción se reemplaza con GET /admin/usuarios
  List<Map<String, dynamic>> _usuarios = [
    {
      'id': 1,
      'nombres': 'Cristhian',
      'apellidos': 'Administrador',
      'correo': 'admin@lastbite.hn',
      'roles': ['ADMIN', 'COMERCIO', 'CLIENTE'],
    },
    {
      'id': 2,
      'nombres': 'Carlos',
      'apellidos': 'Cajero',
      'correo': 'carlos.trigal@lastbite.hn',
      'roles': ['COMERCIO'],
    },
    {
      'id': 3,
      'nombres': 'María',
      'apellidos': 'Gómez',
      'correo': 'maria.gomez@gmail.com',
      'roles': ['CLIENTE'],
    },
  ];

  final List<String> _rolesDisponibles = ['CLIENTE', 'COMERCIO', 'ADMIN'];

  Future<void> _toggleRol(int usuarioId, String rol, bool asignar) async {
    setState(() => _isLoading = true);

    try {
      final endpoint = asignar ? '/admin/asignar-rol' : '/admin/remover-rol';
      final response = await ApiClient.post(endpoint, {
        'usuarioId': usuarioId,
        'rol': rol,
      });

      if (response.statusCode == 200) {
        setState(() {
          final idx = _usuarios.indexWhere((u) => u['id'] == usuarioId);
          if (idx != -1) {
            final roles = List<String>.from(_usuarios[idx]['roles']);
            if (asignar) {
              if (!roles.contains(rol)) roles.add(rol);
            } else {
              roles.remove(rol);
            }
            _usuarios[idx]['roles'] = roles;
          }
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              asignar ? 'Rol $rol asignado.' : 'Rol $rol removido.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _colorRol(String rol) {
    switch (rol) {
      case 'ADMIN':
        return const Color(0xFFFFF3E0);
      case 'COMERCIO':
        return AppTheme.primaryLight;
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Color _colorTextoRol(String rol) {
    switch (rol) {
      case 'ADMIN':
        return const Color(0xFFE65100);
      case 'COMERCIO':
        return AppTheme.primaryDark;
      default:
        return const Color(0xFF1B5E20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Roles y accesos'),
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Cerrar sesión',
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Cerrar sesión'),
                content: const Text('¿Salir del panel de administración?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: const Text('Salir'),
                  ),
                ],
              ),
            );
            if (ok != true || !mounted) return;
            await AuthService.logout();
            Navigator.pushReplacementNamed(context, '/bienvenida');
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Nuevo usuario',
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, '/admin-crear-usuario'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _usuarios.length,
              itemBuilder: (context, i) {
                final u = _usuarios[i];
                final roles = List<String>.from(u['roles']);
                final inicial =
                    (u['nombres'] as String).isNotEmpty
                        ? (u['nombres'] as String)[0].toUpperCase()
                        : '?';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Cabecera del usuario ──────────────────────
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                inicial,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${u['nombres']} ${u['apellidos']}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    u['correo'],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        const Text(
                          'PERMISOS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Chips de roles ────────────────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _rolesDisponibles.map((rol) {
                            final tieneRol = roles.contains(rol);
                            return FilterChip(
                              label: Text(
                                rol,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: tieneRol
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: tieneRol
                                      ? _colorTextoRol(rol)
                                      : AppTheme.textSecondary,
                                ),
                              ),
                              selected: tieneRol,
                              selectedColor: _colorRol(rol),
                              backgroundColor: AppTheme.backgroundCard,
                              checkmarkColor: _colorTextoRol(rol),
                              side: BorderSide(
                                color: tieneRol
                                    ? _colorTextoRol(rol).withValues(alpha: 0.4)
                                    : AppTheme.borderLight,
                              ),
                              onSelected: (val) =>
                                  _toggleRol(u['id'] as int, rol, val),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/network/api_client.dart';
import '../../services/sucursal_service.dart';
import '../../models/asignacion_model.dart';

class AdminCrearUsuarioScreen extends StatefulWidget {
  const AdminCrearUsuarioScreen({super.key});

  @override
  State<AdminCrearUsuarioScreen> createState() =>
      _AdminCrearUsuarioScreenState();
}

class _AdminCrearUsuarioScreenState extends State<AdminCrearUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombresController   = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController    = TextEditingController();
  final _telefonoController  = TextEditingController();
  final _passwordController  = TextEditingController();

  String _rolSeleccionado = 'COMERCIO';
  int? _sucursalSeleccionadaId;
  bool _isLoading = false;
  bool _obscurePassword = true;

  List<Asignacion> _sucursales = [];
  bool _cargandoSucursales = false;

  @override
  void initState() {
    super.initState();
    _cargarSucursales();
  }

  Future<void> _cargarSucursales() async {
    setState(() => _cargandoSucursales = true);
    try {
      final lista = await SucursalService.obtenerMisSucursales();
      if (mounted) {
        setState(() {
          _sucursales = lista;
          if (lista.isNotEmpty) _sucursalSeleccionadaId = lista.first.sucursalId;
          _cargandoSucursales = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargandoSucursales = false);
    }
  }

  Future<void> _handleCrearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final body = {
        'nombres':    _nombresController.text.trim(),
        'apellidos':  _apellidosController.text.trim(),
        'correo':     _correoController.text.trim(),
        'telefono':   _telefonoController.text.trim(),
        'contrasena': _passwordController.text.trim(),
        'rol':        _rolSeleccionado,
        if (_rolSeleccionado == 'COMERCIO' && _sucursalSeleccionadaId != null)
          'sucursalId': _sucursalSeleccionadaId,
      };

      final response = await ApiClient.post('/auth/registro', body);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario $_rolSeleccionado registrado con éxito.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('No se pudo crear el usuario. Código ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Crear usuario'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Encabezado ──────────────────────────────────────────
                const Text(
                  'Alta de personal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Registrá cajeros, encargados o administradores.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 28),

                // ── Nombres ─────────────────────────────────────────────
                TextFormField(
                  controller: _nombresController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombres',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 14),

                // ── Apellidos ───────────────────────────────────────────
                TextFormField(
                  controller: _apellidosController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Apellidos',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 14),

                // ── Correo ──────────────────────────────────────────────
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correo corporativo / personal',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo requerido';
                    if (!v.contains('@')) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Teléfono ────────────────────────────────────────────
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono de contacto',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 14),

                // ── Selector de rol ─────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: _rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Rol del sistema',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'COMERCIO',
                      child: Text('Personal de comercio (cajero / encargado)'),
                    ),
                    DropdownMenuItem(
                      value: 'ADMIN',
                      child: Text('Administrador del sistema'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _rolSeleccionado = val);
                  },
                ),
                const SizedBox(height: 14),

                // ── Sucursal (solo rol COMERCIO) ────────────────────────
                if (_rolSeleccionado == 'COMERCIO') ...[
                  _cargandoSucursales
                      ? const LinearProgressIndicator()
                      : DropdownButtonFormField<int>(
                          initialValue: _sucursalSeleccionadaId,
                          decoration: const InputDecoration(
                            labelText: 'Sucursal asignada',
                            prefixIcon: Icon(Icons.storefront_outlined),
                          ),
                          items: _sucursales.map((asignacion) {
                            return DropdownMenuItem<int>(
                              value: asignacion.sucursalId,
                              child: Text(
                                asignacion.sucursal,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _sucursalSeleccionadaId = val),
                          validator: (v) =>
                              v == null ? 'Seleccioná una sucursal' : null,
                        ),
                  const SizedBox(height: 14),
                ],

                // ── Contraseña ──────────────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleCrearUsuario(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña asignada',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── Botón guardar ───────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCrearUsuario,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.save_rounded),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Registrar usuario'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
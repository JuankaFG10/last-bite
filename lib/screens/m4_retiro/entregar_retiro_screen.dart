import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../models/entrega_model.dart';
import '../../services/retiro_service.dart';

class EntregarRetiroScreen extends StatefulWidget {
  const EntregarRetiroScreen({super.key});

  @override
  State<EntregarRetiroScreen> createState() => _EntregarRetiroScreenState();
}

class _EntregarRetiroScreenState extends State<EntregarRetiroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();

  bool _isLoading = false;
  Entrega? _ultimaEntrega;
  String? _error;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _ultimaEntrega = null;
    });

    try {
      final entrega = await RetiroService.retirar(
        _codigoController.text.trim().toUpperCase(),
      );
      if (!mounted) return;
      setState(() {
        _ultimaEntrega = entrega;
        _isLoading = false;
      });
      _codigoController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Entregar bolsa'),
        backgroundColor: AppTheme.backgroundMain,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Validar código de retiro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pedile al cliente el código que le muestra la app y escribilo acá.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _codigoController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    hintText: 'AB12CD',
                  ),
                  onFieldSubmitted: (_) => _validar(),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingresá el código' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _validar,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Validar y entregar'),
                ),
                const SizedBox(height: 24),
                if (_error != null) _ErrorCard(mensaje: _error!),
                if (_ultimaEntrega != null) _EntregaCard(entrega: _ultimaEntrega!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String mensaje;
  const _ErrorCard({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAE8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE28379)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: Color(0xFF8A3A34), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntregaCard extends StatelessWidget {
  final Entrega entrega;
  const _EntregaCard({required this.entrega});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.badgeTagBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle, color: AppTheme.primary),
              SizedBox(width: 10),
              Text(
                'Entrega registrada',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Cliente: ${entrega.cliente}',
              style: const TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Bolsa: ${entrega.bolsa} · x${entrega.cantidad}',
              style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

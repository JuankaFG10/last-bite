import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/config/estados_ui.dart';
import '../../models/liquidacion_model.dart';
import '../../services/liquidacion_service.dart';

class LiquidacionDetalleScreen extends StatefulWidget {
  final int liquidacionId;
  const LiquidacionDetalleScreen({super.key, required this.liquidacionId});

  @override
  State<LiquidacionDetalleScreen> createState() => _LiquidacionDetalleScreenState();
}

class _LiquidacionDetalleScreenState extends State<LiquidacionDetalleScreen> {
  LiquidacionDetalle? _detalle;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final d = await LiquidacionService.detalle(widget.liquidacionId);
      if (!mounted) return;
      setState(() {
        _detalle = d;
        _isLoading = false;
      });
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
        title: const Text('Detalle de liquidación'),
        backgroundColor: AppTheme.backgroundMain,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(child: _buildBody()),
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
              const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final d = _detalle!;
    final estado = EstadoUi.deLiquidacion(d.estado);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${d.desde}  →  ${d.hasta}',
                        style: Theme.of(context).textTheme.headlineMedium),
                    EstadoBadge(estado: estado),
                  ],
                ),
                const Divider(height: 28),
                _Fila('Ventas', 'L. ${d.ventas.toStringAsFixed(2)}'),
                _Fila('Comisión', 'L. ${d.comision.toStringAsFixed(2)}'),
                const Divider(height: 24),
                _Fila('Total a liquidar', 'L. ${d.total.toStringAsFixed(2)}', destacado: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Reservas incluidas (${d.detalle.length})',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        if (d.detalle.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No hay reservas en este corte.',
                style: TextStyle(color: AppTheme.textSecondary)),
          )
        else
          ...d.detalle.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.codigo,
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                subtitle: Text('${item.bolsa} · ${item.fecha}'),
                trailing: Text('L. ${item.monto.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool destacado;
  const _Fila(this.etiqueta, this.valor, {this.destacado = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: TextStyle(
                color: destacado ? AppTheme.textPrimary : AppTheme.textMuted,
                fontWeight: destacado ? FontWeight.w700 : FontWeight.w400,
                fontSize: destacado ? 15 : 13,
              )),
          Text(valor,
              style: TextStyle(
                color: destacado ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: destacado ? 17 : 13,
              )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../core/config/estados_ui.dart';
import '../../models/reserva_panel_model.dart';
import '../../services/retiro_service.dart';

class ReservasDelDiaScreen extends StatefulWidget {
  final int sucursalId;
  const ReservasDelDiaScreen({super.key, required this.sucursalId});

  @override
  State<ReservasDelDiaScreen> createState() => _ReservasDelDiaScreenState();
}

class _ReservasDelDiaScreenState extends State<ReservasDelDiaScreen> {
  DateTime _fecha = DateTime.now();
  List<ReservaPanel>? _reservas;
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
      final lista = await RetiroService.reservasDelDia(
        widget.sucursalId,
        fecha: _fecha,
      );
      if (!mounted) return;
      setState(() {
        _reservas = lista;
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

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (elegida == null) return;
    setState(() => _fecha = elegida);
    _cargar();
  }

  String get _fechaLegible {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final hoy = DateTime.now();
    final esHoy = _fecha.year == hoy.year &&
        _fecha.month == hoy.month &&
        _fecha.day == hoy.day;
    if (esHoy) return 'Hoy';
    return '${_fecha.day} ${meses[_fecha.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Reservas del día'),
        backgroundColor: AppTheme.backgroundMain,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _elegirFecha,
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(_fechaLegible),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
          const SizedBox(width: 8),
        ],
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
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final reservas = _reservas ?? [];

    if (reservas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(
                child: Text(
                  'No hay reservas para este día.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: reservas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _ReservaTile(reserva: reservas[i]),
      ),
    );
  }
}

class _ReservaTile extends StatelessWidget {
  final ReservaPanel reserva;
  const _ReservaTile({required this.reserva});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoUi.deReserva(reserva.estadoReserva);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _mostrarDetalle(context, reserva),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reserva.codigo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  EstadoBadge(estado: estado),
                ],
              ),
              const SizedBox(height: 8),
              Text(reserva.cliente, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                '${reserva.bolsa} · x${reserva.cantidad}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${ReservaPanel.horaCorta(reserva.horaInicioRetiro)} – ${ReservaPanel.horaCorta(reserva.horaFinRetiro)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const Spacer(),
                  Text(
                    'L. ${reserva.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, ReservaPanel r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.codigo, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _Fila('Cliente', r.cliente),
            if (r.clienteTelefono != null) _Fila('Teléfono', r.clienteTelefono!),
            _Fila('Bolsa', r.bolsa),
            _Fila('Cantidad', '${r.cantidad}'),
            _Fila('Total', 'L. ${r.total.toStringAsFixed(2)}'),
            _Fila('Estado de pago', r.estadoPago ?? '—'),
            if (r.entregadoPor != null) _Fila('Entregado por', r.entregadoPor!),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Fila(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(etiqueta, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

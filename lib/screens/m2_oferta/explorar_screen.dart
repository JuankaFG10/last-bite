import 'package:flutter/material.dart';
import '../../core/config/theme.dart';
import '../../models/publicacion_model.dart';
import '../../models/metodo_pago_model.dart';
import '../../services/publicacion_service.dart';
import '../../services/metodo_pago_service.dart';
import '../../services/reserva_service.dart';

/// Agrupa las publicaciones de una misma sucursal, para mostrarlas como
/// una tarjeta de "restaurante" con sus bolsas disponibles adentro.
class _GrupoComercio {
  final int sucursalId;
  final String sucursal;
  final String nombreComercial;
  final String rubro;
  final List<Publicacion> bolsas;

  _GrupoComercio({
    required this.sucursalId,
    required this.sucursal,
    required this.nombreComercial,
    required this.rubro,
    required this.bolsas,
  });
}

class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  List<_GrupoComercio>? _grupos;
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
      final publicaciones = await PublicacionService.vigentes();

      // Agrupar por sucursal, en el orden en que van apareciendo.
      final Map<int, _GrupoComercio> mapa = {};
      for (final p in publicaciones) {
        mapa.putIfAbsent(
          p.sucursalId,
          () => _GrupoComercio(
            sucursalId: p.sucursalId,
            sucursal: p.sucursal,
            nombreComercial: p.nombreComercial,
            rubro: p.rubro,
            bolsas: [],
          ),
        );
        mapa[p.sucursalId]!.bolsas.add(p);
      }

      if (!mounted) return;
      setState(() {
        _grupos = mapa.values.toList();
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
        title: const Text('Bolsas disponibles'),
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

    final grupos = _grupos ?? [];

    if (grupos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(
                child: Text(
                  'No hay bolsas disponibles en este momento.',
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
        itemCount: grupos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, i) => _RestauranteCard(grupo: grupos[i]),
      ),
    );
  }
}

class _RestauranteCard extends StatelessWidget {
  final _GrupoComercio grupo;
  const _RestauranteCard({required this.grupo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.badgeTagBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grupo.nombreComercial,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${grupo.sucursal} · ${grupo.rubro}',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...grupo.bolsas.map((p) => _BolsaTile(publicacion: p)),
        ],
      ),
    );
  }
}

class _BolsaTile extends StatelessWidget {
  final Publicacion publicacion;
  const _BolsaTile({required this.publicacion});

  @override
  Widget build(BuildContext context) {
    final agotada = publicacion.cantidadDisponible <= 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publicacion.bolsa,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
                const SizedBox(height: 2),
                Text(
                  publicacion.tipoAlimento,
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${Publicacion.horaCorta(publicacion.horaInicioRetiro)} – ${Publicacion.horaCorta(publicacion.horaFinRetiro)}',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'L. ${publicacion.valorEstimado.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'L. ${publicacion.precioVenta.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (publicacion.descuentoPct > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.badgeTagBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${publicacion.descuentoPct}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: agotada ? null : () => _abrirReserva(context, publicacion),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(agotada ? 'Agotada' : 'Reservar'),
                ),
                const SizedBox(height: 4),
                Text(
                  agotada ? '' : 'Quedan ${publicacion.cantidadDisponible}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _abrirReserva(BuildContext context, Publicacion publicacion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReservarSheet(publicacion: publicacion),
    );
  }
}

class _ReservarSheet extends StatefulWidget {
  final Publicacion publicacion;
  const _ReservarSheet({required this.publicacion});

  @override
  State<_ReservarSheet> createState() => _ReservarSheetState();
}

class _ReservarSheetState extends State<_ReservarSheet> {
  int _cantidad = 1;
  List<MetodoPago>? _metodos;
  int? _metodoSeleccionadoId;
  bool _cargandoMetodos = true;
  bool _reservando = false;
  String? _error;
  ReservaCreadaVista? _exito;

  @override
  void initState() {
    super.initState();
    _cargarMetodos();
  }

  Future<void> _cargarMetodos() async {
    try {
      final metodos = await MetodoPagoService.listar();
      if (!mounted) return;
      setState(() {
        _metodos = metodos;
        _metodoSeleccionadoId = metodos.isNotEmpty ? metodos.first.id : null;
        _cargandoMetodos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los métodos de pago.';
        _cargandoMetodos = false;
      });
    }
  }

  Future<void> _confirmar() async {
    if (_metodoSeleccionadoId == null) return;
    setState(() {
      _reservando = true;
      _error = null;
    });
    try {
      final creada = await ReservaService.crear(
        publicacionId: widget.publicacion.publicacionId,
        cantidad: _cantidad,
        metodoPagoId: _metodoSeleccionadoId!,
      );
      if (!mounted) return;
      setState(() {
        _exito = ReservaCreadaVista(codigo: creada.codigo, total: creada.total);
        _reservando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _reservando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _exito != null ? _buildExito() : _buildFormulario(),
      ),
    );
  }

  List<Widget> _buildExito() {
    return [
      const Icon(Icons.check_circle, color: AppTheme.primary, size: 40),
      const SizedBox(height: 12),
      const Text(
        '¡Reserva confirmada!',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      const SizedBox(height: 8),
      Text(
        'Código: ${_exito!.codigo}',
        style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 4),
      Text('Total: L. ${_exito!.total.toStringAsFixed(2)}'),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Listo'),
      ),
    ];
  }

  List<Widget> _buildFormulario() {
    return [
      Text(widget.publicacion.bolsa,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      const SizedBox(height: 4),
      Text(
        'L. ${widget.publicacion.precioVenta.toStringAsFixed(2)} c/u',
        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Cantidad'),
          Row(
            children: [
              IconButton(
                onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_cantidad', style: const TextStyle(fontWeight: FontWeight.w700)),
              IconButton(
                onPressed: _cantidad < widget.publicacion.cantidadDisponible
                    ? () => setState(() => _cantidad++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Text('Método de pago'),
      const SizedBox(height: 8),
      if (_cargandoMetodos)
        const Center(child: CircularProgressIndicator())
      else
        ...?_metodos?.map((m) => RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              value: m.id,
              groupValue: _metodoSeleccionadoId,
              onChanged: (v) => setState(() => _metodoSeleccionadoId = v),
              title: Text(m.nombre),
              activeColor: AppTheme.primary,
            )),
      const SizedBox(height: 12),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _reservando ? null : _confirmar,
          child: _reservando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text('Reservar · L. ${(widget.publicacion.precioVenta * _cantidad).toStringAsFixed(2)}'),
        ),
      ),
    ];
  }
}

class ReservaCreadaVista {
  final String codigo;
  final double total;
  ReservaCreadaVista({required this.codigo, required this.total});
}

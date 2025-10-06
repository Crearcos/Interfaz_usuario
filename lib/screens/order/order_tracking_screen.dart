import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../suscription/subscription_plans_screen.dart';
import '../cart/cart.dart';
import '../support/support_issue_screen.dart';
import 'rating_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String payMethodLabel;   // ej: "Pago tarjeta" / "Pago efectivo"
  final String address;          // ej: "Av. 9 de Octubre"
  final LatLng mapCenter;        // centro del mapa (sin API key)

  const OrderTrackingScreen({
    super.key,
    required this.payMethodLabel,
    required this.address,
    this.mapCenter = const LatLng(-2.170998, -79.922359), // Guayaquil centro aprox
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

enum _Stage { received, preparing, arrived }

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const purple = Color(0xFF6A1B9A);
  static const bg = Color(0xFFF8F2F7);
  _Stage stage = _Stage.received;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Demo: avanza automáticamente por etapas (puedes reemplazar por stream del backend)
    _timer = Timer.periodic(const Duration(seconds: 7), (t) {
      if (!mounted) return;
      setState(() {
        if (stage == _Stage.received) {
          stage = _Stage.preparing;
        } else if (stage == _Stage.preparing) {
          stage = _Stage.arrived;
          _timer?.cancel();
          _showArrivedDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _p(num n) => '\$${n.toStringAsFixed(2).replaceAll('.', ',')}';

  String _itemsTitle() {
    final total = Cart.I.totalQty;
    if (total <= 0) return '1 producto';
    return '$total producto${total == 1 ? '' : 's'}';
  }

  String _firstItemName() {
    if (Cart.I.items.isEmpty) return 'Producto';
    return Cart.I.items.first.dish['name']?.toString() ?? 'Producto';
  }

  String _timeWindow() {
    final now = DateTime.now();
    final from = now.add(const Duration(minutes: 30));
    final to = now.add(const Duration(minutes: 45));
    String f(int x) => x.toString().padLeft(2, '0');
    return '${f(from.hour)}:${f(from.minute)} - ${f(to.hour)}:${f(to.minute)}';
  }

  void _showArrivedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0AD14C),
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo placeholder
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.restaurant, color: Colors.green),
              ),
              const SizedBox(height: 10),
              const Text(
                'YumiFit',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu pedido ya llegó',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // cierra dialog
                        // Va a rating
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RatingScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Sí'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // cierra dialog
                        // Flujo de soporte
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SupportIssueScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('No'),
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

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (stage) {
      _Stage.received   => 'Hemos recibido tu pedido',
      _Stage.preparing  => 'Preparando tu pedido',
      _Stage.arrived    => 'Tu pedido ha llegado',
    };

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Header simple
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Tarjeta de llegada estimada + progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Llegada estimada',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      _timeWindow(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 22),
                    ),
                    const SizedBox(height: 10),
                    _progressSegments(stage),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, color: Color(0xFF6A1B9A)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Mapa (OpenStreetMap via flutter_map, sin API keys)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: widget.mapCenter,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none, // solo visual
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.interfaz_usuario',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.mapCenter,
                            width: 40, height: 40,
                            child: const Icon(Icons.location_pin,
                                size: 38, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Detalles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_itemsTitle(),
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(_firstItemName()),
                  const SizedBox(height: 14),
                  const Text('Pago tarjeta', // label del bloque
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  Text(_p(Cart.I.totalPrice + 0.10)), // total aprox del pedido
                  const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Suscríbete al Plan\nPremium',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () {
                // Opción A: lista de planes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
                );
              },
              child: const Text('Suscribirme'),
            ),
          ],
        ),
        const SizedBox(height: 14),
                  const Text('Dirección',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  Text(widget.address),
                  const SizedBox(height: 24),
                  // Botón de cancelar (gris deshabilitado como en el mock)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar pedido'),
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

  Widget _progressSegments(_Stage s) {
    final i = switch (s) {
      _Stage.received => 0,
      _Stage.preparing => 1,
      _Stage.arrived => 2,
    };

    Widget seg(bool active) => Expanded(
      child: Container(
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6A1B9A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black26),
        ),
      ),
    );

    return Row(
      children: [
        seg(i >= 0),
        seg(i >= 1),
        seg(i >= 2),
      ],
    );
  }
}

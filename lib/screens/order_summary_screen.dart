import 'package:flutter/material.dart';
import 'cart/cart.dart'; // ajusta ruta si es necesario
import '../widgets/add_to_cart_sheet.dart'; // ajusta ruta si es necesario
import 'checkout_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> addedDish;
  final List<Map<String, dynamic>> allDishes; // para sugerencias

  const OrderSummaryScreen({
    super.key,
    required this.addedDish,
    required this.allDishes,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  // Estilos
  static const textMain = Colors.black87;
  static const purple = Color(0xFF6A1B9A);
  static const green = Color(0xFF0AD14C);
  static const bg = Color(0xFFF8F2F7);

  // Alto fijo del carrusel para que no se “monte” con lo de abajo
  static const double _kSugHeight = 210;

  String _formatPrice(num n) =>
      '\$${n.toStringAsFixed(2).replaceAll('.', ',')}';

  String get _itemId =>
      (widget.addedDish['id'] ?? widget.addedDish['name']).toString();

  // Totales (puedes ajustar reglas aquí)
  double get _productsTotal => Cart.I.totalPrice;
  double get _shipping => 0.0;
  double get _serviceFee => 0.10;
  double get _subtotal => _productsTotal + _shipping + _serviceFee;

  int _currentQty() {
    final e = Cart.I.items.firstWhere(
          (e) => e.id == _itemId,
      orElse: () => CartItem(widget.addedDish, 0),
    );
    return e.qty;
  }

  List<Map<String, dynamic>> _suggestions() {
    final cat = (widget.addedDish['category'] ?? '').toString();
    final pool = widget.allDishes.where((d) {
      final id = (d['id'] ?? d['name']).toString();
      final sameCat = cat.isEmpty ? true : d['category'] == cat;
      return id != _itemId && sameCat;
    }).toList();
    pool.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return pool.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final qty = _currentQty();
    final price = (widget.addedDish['price'] as num).toDouble();
    final suggestions = _suggestions(); // calcular una sola vez

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Expanded(
                        child: Text(
                          'Mi pedido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: navegar a carrito completo si lo deseas
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),
                    ],
                  ),
                ),

                // Título + descripción + precio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.addedDish['name'] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textMain,
                        ),
                      ),
                      if ((widget.addedDish['desc'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.addedDish['desc'],
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          _formatPrice(price),
                          style: const TextStyle(
                            color: purple,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card del producto: imagen + badges + stepper
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _netImage(widget.addedDish['img']),
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Row(
                            children: [
                              _badge(
                                icon: Icons.timer_outlined,
                                text1: 'Recibes en',
                                text2: '20–30 min',
                              ),
                              const SizedBox(width: 10),
                              _badge(
                                icon: Icons.delivery_dining,
                                text1: 'Envío',
                                text2: 'Gratis',
                                boldSecond: true,
                              ),
                              const Spacer(),
                              _qtyStepper(qty),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sugerencias
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: const Text(
                    '¿Quieres pedir algo más?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textMain,
                    ),
                  ),
                ),
                if (suggestions.isNotEmpty)
                  SizedBox(
                    height: _kSugHeight,
                    child: ListView.separated(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) =>
                          _suggestionCard(suggestions[i], _kSugHeight),
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemCount: suggestions.length,
                    ),
                  ),

                // Resumen
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 22, 16, 8),
                  child: const Text(
                    'Resumen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textMain,
                    ),
                  ),
                ),
                _summaryRow('Productos', _formatPrice(_productsTotal)),
                _summaryRow('Envío',
                    _shipping == 0 ? '\$0' : _formatPrice(_shipping)),
                _summaryRow('Tarifa de servicio',
                    _formatPrice(_serviceFee)),
              ],
            ),

            // Barra inferior: Subtotal + Ir a pagar
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatPrice(_subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Ir a pagar',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helpers =================

  // Imagen de red robusta (placeholder en fallo)
  Widget _netImage(dynamic url) {
    final u = (url ?? '').toString();
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(18),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          u.isEmpty ? 'about:blank' : u,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.broken_image_outlined,
                    size: 36, color: Colors.black26),
                SizedBox(height: 6),
                Text(
                  'Imagen no disponible',
                  style:
                  TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String text1,
    required String text2,
    bool boldSecond = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text1,
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 12)),
              Text(
                text2,
                style: TextStyle(
                  fontWeight:
                  boldSecond ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyStepper(int qty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyBtn(
          icon: Icons.remove,
          onTap: () {
            final newQty = (qty - 1).clamp(0, 999);
            Cart.I.setQty(_itemId, newQty);
            setState(() {});
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        _qtyBtn(
          icon: Icons.add,
          onTap: () {
            Cart.I.setQty(_itemId, qty + 1);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }

  Widget _suggestionCard(Map<String, dynamic> d, double sugHeight) {
    return SizedBox(
      width: 200,
      height: sugHeight, // asegura altura suficiente
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  (d['img'] ?? '').toString(),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined,
                        size: 32, color: Colors.black26),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Nombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                (d['name'] ?? '').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),

            // Precio
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(_formatPrice(d['price'] as num)),
            ),

            // Empuja el botón hacia el fondo
            const Spacer(),

            // Botón
            Padding(
              padding:
              const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => showAddToCartSheet(
                    context,
                    d,
                    allDishes: widget.allDishes,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Añadir al carrito',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

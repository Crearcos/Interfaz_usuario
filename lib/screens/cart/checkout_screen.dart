import 'package:flutter/material.dart';
import 'cart.dart';
import '../order/order_tracking_screen.dart'; // ⬅️ ajusta la ruta si tu archivo está en /screens

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum _PayMethod { card, cash }

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const bg = Color(0xFFF8F2F7);
  static const textMain = Colors.black87;
  static const green = Color(0xFF0AD14C);
  static const purple = Color(0xFF6A1B9A);

  final _pageCtrl = PageController();
  _PayMethod _method = _PayMethod.card;

  // “Tarjeta agregada” demo
  bool _hasCard = false;
  String _maskedCard = '•••• •••• •••• 4242';

  // Efectivo
  final TextEditingController _cashCtrl = TextEditingController();

  // Totales (mismo criterio que en OrderSummary)
  String _p(num n) => '\$${n.toStringAsFixed(2).replaceAll('.', ',')}';
  double get _productsTotal => Cart.I.totalPrice;
  double get _shipping => 0.0;
  double get _serviceFee => 0.10;
  double get _total => _productsTotal + _shipping + _serviceFee;

  bool get _cashOk {
    final raw = _cashCtrl.text.trim().replaceAll(',', '.');
    final val = double.tryParse(raw) ?? 0.0;
    return val >= _total;
  }

  // Etiqueta y dirección que enviaremos al tracking
  String get _payMethodLabel =>
      _method == _PayMethod.card ? 'Pago tarjeta' : 'Pago efectivo';
  String get _address => 'Av. 9 de Octubre';

  @override
  void dispose() {
    _pageCtrl.dispose();
    _cashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: [
                _header(context),
                const SizedBox(height: 8),
                _subtitle('¿Cómo quieres pagar?'),
                const SizedBox(height: 8),
                _paymentCarousel(),
                const SizedBox(height: 18),
                _subtitle('Datos de entrega'),
                _deliveryBlock(),
                const SizedBox(height: 18),
                _subtitle('Datos de facturación'),
                _billingBlock(),
                const SizedBox(height: 18),
                _subtitle('Resumen'),
                _summaryRow('Productos', _p(_productsTotal)),
                _summaryRow('Envío', _shipping == 0 ? '\$0' : _p(_shipping)),
                _summaryRow('Tarifa de servicio', _p(_serviceFee)),
              ],
            ),

            // Barra inferior: Total + Pedir
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
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    const Spacer(),
                    Text(
                      _p(_total),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _canPlaceOrder ? _placeOrder : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Pedir',
                          style: TextStyle(fontWeight: FontWeight.w800)),
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

  // ===================== UI sections =====================

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Expanded(
            child: Text(
              'Confirmar tu pedido',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
    );
  }

  Widget _subtitle(String t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      t,
      style: const TextStyle(
          fontWeight: FontWeight.w900, fontSize: 18, color: textMain),
    ),
  );

  // ---------- Carrusel de métodos de pago (swipe) ----------
  Widget _paymentCarousel() {
    return Column(
      children: [
        // Indicadores tipo “segmentos”
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _segmentButton(
                label: 'Tarjeta',
                active: _method == _PayMethod.card,
                onTap: () => _goTo(0, _PayMethod.card),
              ),
              const SizedBox(width: 8),
              _segmentButton(
                label: 'Efectivo',
                active: _method == _PayMethod.cash,
                onTap: () => _goTo(1, _PayMethod.cash),
              ),
            ],
          ),
        ),
        // Páginas
        SizedBox(
          height: 150,
          child: PageView(
            controller: _pageCtrl,
            onPageChanged: (i) =>
                setState(() => _method = i == 0 ? _PayMethod.card : _PayMethod.cash),
            children: [
              _cardBox(),
              _cashBox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _segmentButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black26),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: active ? textMain : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  void _goTo(int page, _PayMethod m) {
    setState(() => _method = m);
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ---------- Caja Tarjeta ----------
  Widget _cardBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black26),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _hasCard ? _changeCard : _addCardFlow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_hasCard ? 'Tarjeta guardada' : 'Agregar tarjeta',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        _hasCard ? _maskedCard : 'Débito o crédito',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      if (!_hasCard) const SizedBox(height: 10),
                      if (!_hasCard)
                        Row(
                          children: [
                            _logoChip('VISA', const Color(0xFF1A1F71)),
                            const SizedBox(width: 6),
                            _logoChip('MC', const Color(0xFFF79E1B)),
                            const SizedBox(width: 6),
                            _logoChip('AMEX', const Color(0xFF2E77BC)),
                          ],
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Caja Efectivo ----------
  Widget _cashBox() {
    final hint = 'Ingresa el monto';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black26),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.payments_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Efectivo',
                        style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cashCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 6),
                    if (_cashCtrl.text.isNotEmpty) _cashFeedback(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cashFeedback() {
    final raw = _cashCtrl.text.trim().replaceAll(',', '.');
    final val = double.tryParse(raw) ?? 0.0;
    final diff = (val - _total);
    if (val <= 0) {
      return const Text('Monto inválido', style: TextStyle(color: Colors.red));
    }
    if (diff < 0) {
      return Text('Faltan ${_p(diff.abs())}',
          style: const TextStyle(color: Colors.red));
    }
    return Text('Cambio: ${_p(diff)}',
        style: const TextStyle(color: Colors.black54));
  }

  // ---------- Bloques de info ----------
  Widget _deliveryBlock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              Row(
                children: const [
                  Icon(Icons.delivery_dining),
                  SizedBox(width: 10),
                  Expanded(child: Text('Delivery\n20–30 min')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Trabajo\nAv. 9 de Octubre')),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cambiar dirección (pendiente)'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billingBlock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_outlined),
              const SizedBox(width: 10),
              const Expanded(child: Text('No has agregado tus datos')),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agregar datos de facturación (pendiente)'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
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

  // ===================== Helpers =====================

  Widget _logoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: color,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _addCardFlow() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => const _AddCardSheet(),
    );
    if (ok == true) {
      setState(() => _hasCard = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarjeta agregada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _changeCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambiar tarjeta (pendiente)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool get _canPlaceOrder {
    if (_method == _PayMethod.card) return _hasCard;
    return _cashOk;
  }

  // ⬇️ Al confirmar, pasamos a OrderTracking con método y dirección
  void _placeOrder() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(
          payMethodLabel: _payMethodLabel,
          address: _address,
        ),
      ),
    );
    // Si quieres limpiar el carrito aquí:
    // Cart.I.clear();
  }
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _numCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _numCtrl.dispose();
    _nameCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  bool get _valid {
    final n = _numCtrl.text.replaceAll(' ', '');
    return n.length >= 12 &&
        _nameCtrl.text.trim().isNotEmpty &&
        _expCtrl.text.trim().isNotEmpty &&
        _cvvCtrl.text.trim().length >= 3;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Agregar tarjeta',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _numCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de tarjeta',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del titular',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expCtrl,
                    decoration: const InputDecoration(
                      labelText: 'MM/AA',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cvvCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _valid ? () => Navigator.pop(context, true) : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Guardar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

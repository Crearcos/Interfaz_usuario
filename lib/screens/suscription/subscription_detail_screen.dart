import 'package:flutter/material.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final String planName;
  final double price;

  const SubscriptionDetailScreen({
    super.key,
    required this.planName,
    required this.price,
  });

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  static const green = Color(0xFF0AD14C);
  static const purple = Color(0xFF6A1B9A);
  static const bg = Color(0xFFF8F2F7);

  bool _accepted = false;
  bool _hasCard = false;
  String _maskedCard = '1234 5555 3456 7890';

  String _p(num n) => '\$${n.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          children: [
            Row(
              children: [
                // Pequeño logo
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                      color: green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.planName} ${_p(widget.price)}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
            ),
            const SizedBox(height: 16),

            // Beneficios (con íconos simples)
            _benefit(icon: Icons.delivery_dining, text: 'Envíos gratis'),
            const SizedBox(height: 12),
            _benefit(
                icon: Icons.local_offer_outlined,
                text: 'Descuentos en el restaurante'),
            const SizedBox(height: 12),
            _benefit(
                icon: Icons.support_agent_outlined,
                text: 'Cita con el nutricionista \$5,00'),
            const SizedBox(height: 24),

            // Caja de agregar tarjeta o tarjeta guardada
            _hasCard ? _savedCardBox() : _addCardBox(),

            const SizedBox(height: 20),

            // T&C
            InkWell(
              onTap: () => setState(() => _accepted = !_accepted),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    onChanged: (v) => setState(() => _accepted = v ?? false),
                  ),
                  const Text.rich(
                    TextSpan(
                      text: 'Acepto los ',
                      children: [
                        TextSpan(
                          text: 'términos y condiciones',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // CTA inferior
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canBuy ? _confirmPurchase : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Suscribirme',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }

  bool get _canBuy => _accepted && _hasCard;

  Widget _benefit({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _addCardBox() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: _addCardFlow,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black26),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Agregar tarjeta de\ncrédito o debito',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _savedCardBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 22, decoration: const BoxDecoration(
            color: Color(0xFF00E233), // verde brillante
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          ),
          const SizedBox(width: 10),
          const Text('Tarjeta de debito',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> _addCardFlow() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _AddCardSheet(),
    );
    if (ok == true) {
      setState(() => _hasCard = true);
      // opcional: setear _maskedCard desde el sheet
    }
  }

  Future<void> _confirmPurchase() async {
    // Mostrar modal verde “Compra exitosa”
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: green,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              // logo
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(Icons.check, color: Colors.green, size: 32),
              ),
              SizedBox(height: 10),
              Text('YumiFit',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20)),
              SizedBox(height: 10),
              Text(
                'Compra exitosa',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22),
              ),
              SizedBox(height: 10),
              Text(
                'Tu suscripción se activó correctamente',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    // Al tocar fuera/cerrar el modal -> regresar al Home
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// ===== Bottom sheet para agregar tarjeta (demo) =====
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

  bool get _valid =>
      _numCtrl.text.replaceAll(' ', '').length >= 12 &&
          _nameCtrl.text.trim().isNotEmpty &&
          _expCtrl.text.trim().isNotEmpty &&
          _cvvCtrl.text.trim().length >= 3;

  @override
  void dispose() {
    _numCtrl.dispose();
    _nameCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
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

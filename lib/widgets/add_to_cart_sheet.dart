import 'package:flutter/material.dart';
import '../screens/cart/cart.dart';
import '../screens/order_summary_screen.dart';

String formatPrice(num n) => '\$${n.toStringAsFixed(2).replaceAll('.', ',')}';

Future<void> showAddToCartSheet(
    BuildContext parentContext,
    Map<String, dynamic> dish, {
      List<Map<String, dynamic>>? allDishes,
    }) {
  return showModalBottomSheet(
    context: parentContext,
    isScrollControlled: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _AddToCartSheet(
      dish: dish,
      parentContext: parentContext,
      allDishes: allDishes,
    ),
  );
}

class _AddToCartSheet extends StatefulWidget {
  final Map<String, dynamic> dish;
  final BuildContext parentContext; // para navegar tras cerrar el sheet
  final List<Map<String, dynamic>>? allDishes;
  const _AddToCartSheet({
    required this.dish,
    required this.parentContext,
    this.allDishes,
  });

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  static const green = Color(0xFF0AD14C);
  static const purple = Color(0xFF6A1B9A);
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final price = (widget.dish['price'] as num).toDouble();
    final total = price * qty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44, height: 4, margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Text(qty == 1 ? '1 producto' : '$qty productos',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const Spacer(),
                Text(
                  formatPrice(total),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 20, color: purple),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QtyBtn(icon: Icons.remove, onTap: () { if (qty > 1) setState(() => qty--); }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$qty',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                _QtyBtn(icon: Icons.add, onTap: () => setState(() => qty++)),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Cart.I.add(widget.dish, qty);
                      Navigator.of(context).pop(); // cierra sheet
                      // Abre "Mi pedido"
                      Navigator.of(widget.parentContext).push(
                        MaterialPageRoute(
                          builder: (_) => OrderSummaryScreen(
                            addedDish: widget.dish,
                            allDishes: widget.allDishes ?? const [],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green, foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

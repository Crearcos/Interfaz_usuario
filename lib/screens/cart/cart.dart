// lib/cart/cart.dart
import 'package:flutter/foundation.dart';

class CartItem {
  final Map<String, dynamic> dish;
  int qty;
  CartItem(this.dish, this.qty);

  double get unitPrice => (dish['price'] as num).toDouble();
  double get total => unitPrice * qty;
  String get id => (dish['id'] ?? dish['name']).toString();
}

class Cart {
  Cart._();
  static final Cart I = Cart._();

  final Map<String, CartItem> _items = {};
  // Para notificar cambios a la UI:
  final ValueNotifier<int> version = ValueNotifier(0);

  void add(Map<String, dynamic> dish, int qty) {
    final id = (dish['id'] ?? dish['name']).toString();
    final existing = _items[id];
    if (existing == null) {
      _items[id] = CartItem(dish, qty);
    } else {
      existing.qty += qty;
    }
    version.value++;
  }

  void setQty(String id, int qty) {
    if (qty <= 0) {
      _items.remove(id);
    } else {
      _items[id]?.qty = qty;
    }
    version.value++;
  }

  void remove(String id) {
    _items.remove(id);
    version.value++;
  }

  void clear() {
    _items.clear();
    version.value++;
  }

  int get totalQty => _items.values.fold(0, (s, e) => s + e.qty);
  double get totalPrice => _items.values.fold(0.0, (s, e) => s + e.total);

  List<CartItem> get items => _items.values.toList(growable: false);
}

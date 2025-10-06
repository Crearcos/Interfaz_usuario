import 'package:flutter/material.dart';
import '../cart/add_to_cart_sheet.dart'; // ajusta ruta según tu estructura

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> allDishes;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.allDishes,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const bg = Color(0xFFF8F2F7);
  static const green = Color(0xFF0AD14C);
  static const textMain = Colors.black87;

  final TextEditingController _searchCtrl = TextEditingController();

  String _formatPrice(num n) => '\$${n.toStringAsFixed(2).replaceAll('.', ',')}';

  // Carga imagen de asset o red según el string
  Widget _dishImage(String src) {
    return src.startsWith('assets/')
        ? Image.asset(src, fit: BoxFit.cover)
        : Image.network(src, fit: BoxFit.cover);
  }

  List<Map<String, dynamic>> get _items {
    // 1) Filtra por categoría
    final base = widget.allDishes.where((d) {
      final cat = (d['category'] ?? '').toString().toLowerCase();
      return cat == widget.categoryName.toLowerCase();
    });

    // 2) Aplica búsqueda (si hay texto)
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return base.toList();

    return base.where((d) {
      final name = (d['name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar con Back y carrito
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // aquí podrías navegar al carrito completo
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ],
                ),
              ),
            ),

            // Buscador
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar platos',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Título de categoría
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textMain,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Grid de platos o vacío
            if (items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                  child: Column(
                    children: const [
                      Icon(Icons.search_off, size: 48, color: Colors.black38),
                      SizedBox(height: 10),
                      Text(
                        'No se encontraron platos',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) => _dishCard(items[i]),
                    childCount: items.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 250,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _dishCard(Map<String, dynamic> d) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 11,
              child: _dishImage(d['img'] as String),
            ),
          ),
          const SizedBox(height: 6),

          // Nombre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              d['name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: textMain,
              ),
            ),
          ),

          // Precio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Text(
              _formatPrice(d['price'] as num),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),

          // Botón -> abre bottom sheet de carrito
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    showAddToCartSheet(context, d, allDishes: widget.allDishes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(34),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Añadir al carrito',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

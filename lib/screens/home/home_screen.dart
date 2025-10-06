import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../catalog/category_screen.dart';
import '../cart/add_to_cart_sheet.dart';
import '../suscription/subscription_plans_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0; // 0: Home, 1: Promos, 2: Pedidos, 3: Perfil

  // Estilos
  static const bg = Color(0xFFF8F2F7);
  static const green = Color(0xFF0AD14C);
  static const textMain = Colors.black87;

  // Carruseles
  final _heroCtrl = PageController(viewportFraction: 0.92);
  int _heroIndex = 0;

  final _promoCtrl = PageController(viewportFraction: 0.92);
  int _promoIndex = 0;

  // HERO (superior)
  final List<String> heroImages = [
    'assets/cocinamos.png',
    'assets/descubre.png',
    'assets/pide.png',
  ];

  // Categorías (thumbnails externas)
  final List<Map<String, String>> categories = [
    {
      'name': 'Ensaladas',
      'img': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=300'
    },
    {
      'name': 'Desayuno',
      'img': 'https://images.unsplash.com/photo-1551218808-94e220e084d2?q=80&w=300'
    },
    {
      'name': 'Almuerzo',
      'img': 'https://images.unsplash.com/photo-1529042410759-befb1204b468?q=80&w=300'
    },
    {
      'name': 'Snacks',
      'img': 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?q=80&w=300'
    },
  ];

  // Platos (assets)
  final List<Map<String, dynamic>> dishes = [
    {
      'name': 'Pescado Sudado con Vegetales',
      'price': 7.90,
      'img': 'assets/pescado_verduras.png',
      'category': 'Almuerzo',
      'desc': 'Filete de pescado blanco al vapor con brócoli, zanahorias baby y tomates cherry.',
      'kcal': '250–280 kcal',
    },
    {
      'name': 'Ensalada con Pollo al Grill',
      'price': 5.90,
      'img': 'assets/ensalada_pollo.png',
      'category': 'Ensaladas',
      'desc': 'Pechuga de pollo a la plancha con lechuga y tomates cherry rojos y amarillos.',
      'kcal': '300–330 kcal',
    },
    {
      'name': 'Ensalada de Frejol',
      'price': 4.50,
      'img': 'assets/ensalada_frejol.png',
      'category': 'Ensaladas',
      'desc': 'Frejoles blancos con zanahoria, cebolla morada y perejil. Alta en fibra.',
      'kcal': '≈220 kcal',
    },
    {
      'name': 'Ensalada de Atún',
      'price': 6.50,
      'img': 'assets/ensalada_atun.png',
      'category': 'Ensaladas',
      'desc': 'Atún con aguacate, huevo cocido, tomate cherry y hojas verdes.',
      'kcal': '≈350 kcal',
    },
    {
      'name': 'Sopa de Pollo con Verduras',
      'price': 3.50,
      'img': 'assets/sopa_pollo.png',
      'category': 'Almuerzo',
      'desc': 'Caldo ligero con pollo, zanahoria, apio y hierbas frescas.',
      'kcal': '≈150 kcal',
    },
  ];

  // PROMOS (inferior)
  final List<String> promoImages = [
    'assets/ahorra.png',
    'assets/descubre.png',
    'assets/descuento.png',
  ];

  late final List<Map<String, dynamic>> randomFour;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    final pool = [...dishes]..shuffle(rnd);
    randomFour = pool.take(4).toList();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  void _openSubscription([int? _]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
    );
  }

  // helper assets/network
  Widget _dishImage(String src) => src.startsWith('assets/')
      ? Image.asset(src, fit: BoxFit.cover)
      : Image.network(src, fit: BoxFit.cover);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: _bottomBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _topBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _searchField()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _heroCarousel()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _heroDots()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _categoryRowCentered()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // GRID de platos con alto uniforme (sin overflow)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, i) => _dishCard(randomFour[i]),
                  childCount: randomFour.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  // Más alto para evitar overflow en pantallas angostas
                  childAspectRatio: 0.58, // <= clave; sube/baja entre 0.56–0.64 si quieres
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _promoCarousel()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _promoDots()),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  // ======= UI =======

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.black87, size: 22),
          const SizedBox(width: 6),
          const Text('Trabajo',
              style: TextStyle(color: textMain, fontWeight: FontWeight.w800, fontSize: 20)),
          const Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.black87),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar platos',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
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
    );
  }

  Widget _heroCarousel() {
    return SizedBox(
      height: 165,
      child: PageView.builder(
        controller: _heroCtrl,
        onPageChanged: (i) => setState(() => _heroIndex = i),
        itemCount: heroImages.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(heroImages[i], fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _heroDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        heroImages.length,
            (i) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _heroIndex == i ? Colors.grey.shade800 : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _categoryRowCentered() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((c) => _categoryItem(context, c)).toList(),
      ),
    );
  }

  Widget _categoryItem(BuildContext context, Map<String, String> c) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryScreen(categoryName: c['name']!, allDishes: dishes),
        ),
      ),
      borderRadius: BorderRadius.circular(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.shade300),
              image: DecorationImage(image: NetworkImage(c['img']!), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w700, color: textMain)),
        ],
      ),
    );
  }

  // -------- CARD de plato (uniforme y sin overflow) --------
  Widget _dishCard(Map<String, dynamic> d) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen cuadrada 1:1
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            child: AspectRatio(aspectRatio: 1, child: _dishImage(d['img'] as String)),
          ),

          const SizedBox(height: 6),

          // Título con altura fija (2 líneas aprox)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 36, // 34–40; ajusté a 36 para ganar alto útil
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  d['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textMain),
                ),
              ),
            ),
          ),

          // Precio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Text(
              '\$${(d['price'] as num).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),

          const Spacer(),

          // Botón al mismo nivel en todos
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SizedBox(
              width: double.infinity,
              height: 40, // 36–40
              child: ElevatedButton(
                onPressed: () => showAddToCartSheet(context, d, allDishes: dishes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Añadir al carrito',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _promoCtrl,
        onPageChanged: (i) => setState(() => _promoIndex = i),
        itemCount: promoImages.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openSubscription(i),
              child: Ink.image(
                image: AssetImage(promoImages[i]),
                fit: BoxFit.cover,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _promoDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        promoImages.length,
            (i) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _promoIndex == i ? Colors.grey.shade800 : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    // Usa tus iconos SVG de assets/icon/
    const items = [
      {'path': 'assets/icon/home.svg', 'label': 'Home'},
      {'path': 'assets/icon/promociones.svg', 'label': 'Promos'},
      {'path': 'assets/icon/hoja.svg', 'label': 'Pedidos'},
      {'path': 'assets/icon/perfil.svg', 'label': 'Perfil'},
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final active = _tabIndex == i;
            return _BottomItem(
              iconPath: items[i]['path']!,
              active: active,
              onTap: () {
                setState(() => _tabIndex = i);

                if (i == 1) {
                  _openSubscription();
                } else if (i == 3) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                }
              },
            );
          }),
        ),
      ),
    );
  }
}

// ---------------------------------------------
// Widgets para la barra inferior (usar íconos SVG)
// ---------------------------------------------
class _BottomItem extends StatelessWidget {
  final String iconPath;
  final bool active;
  final VoidCallback onTap;

  const _BottomItem({
    required this.iconPath,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.black87 : Colors.black45;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: _AssetIcon(iconPath, color: color, size: 28),
      ),
    );
  }
}

/// Carga un asset (SVG o PNG) y aplica tinte de color.
class _AssetIcon extends StatelessWidget {
  final String path;
  final Color color;
  final double size;

  const _AssetIcon(this.path, {required this.color, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

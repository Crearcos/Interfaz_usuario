import 'dart:math';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estilos
  static const bg = Color(0xFFF8F2F7);
  static const green = Color(0xFF0AD14C);
  static const textMain = Colors.black87;

  // Carruseles
  final _heroCtrl = PageController(viewportFraction: 0.92);
  int _heroIndex = 0;

  final _promoCtrl = PageController(viewportFraction: 0.92);
  int _promoIndex = 0;

  // Imágenes locales para banners principales
  final List<String> heroImages = [
    'assets/b1.png',
    'assets/b2.png',
    'assets/b3.png',
  ];

  // Categorías (siguen en red, pero se pueden pasar a assets)
  final List<Map<String, String>> categories = [
    {'name': 'Ensalada', 'img': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=300'},
    {'name': 'Desayuno', 'img': 'https://images.unsplash.com/photo-1551218808-94e220e084d2?q=80&w=300'},
    {'name': 'Almuerzo', 'img': 'https://images.unsplash.com/photo-1529042410759-befb1204b468?q=80&w=300'},
    {'name': 'Snacks', 'img': 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?q=80&w=300'},
  ];

  // Platos (mock)
  final List<Map<String, dynamic>> dishes = [
    {
      'name': 'Ensalada de Quinoa',
      'price': 8.90,
      'img': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800',
    },
    {
      'name': 'Green Smoothie',
      'price': 4.99,
      'img': 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?q=80&w=800',
    },
    {
      'name': 'Galletas de avena',
      'price': 3.00,
      'img': 'https://images.unsplash.com/photo-1509365465985-25d11c17e812?q=80&w=800',
    },
    {
      'name': 'Crema de tomate',
      'price': 3.99,
      'img': 'https://images.unsplash.com/photo-1543352634-8732c996d6d1?q=80&w=800',
    },
    {
      'name': 'Bowl de frutas',
      'price': 5.50,
      'img': 'https://images.unsplash.com/photo-1490474418585-1fdc8f6f5a3b?q=80&w=800',
    },
  ];

  // Imágenes locales para promociones
  final List<String> promoImages = [
    'assets/p1.png',
    'assets/p2.png',
    'assets/p3.png',
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, i) => _dishCard(randomFour[i]),
                  childCount: randomFour.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 250,
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

  // Top bar
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.black87, size: 22),
          const SizedBox(width: 6),
          const Text(
            'Trabajo',
            style: TextStyle(
              color: textMain,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.black87),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
          ),
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

  // ======= Carrusel con imágenes locales =======
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

  // ======= Categorías centradas =======
  Widget _categoryRowCentered() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((c) => _categoryItem(c)).toList(),
      ),
    );
  }

  Widget _categoryItem(Map<String, String> c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.grey.shade300),
            image: DecorationImage(
              image: NetworkImage(c['img']!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          c['name']!,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: textMain,
          ),
        ),
      ],
    );
  }

  // ======= Cards de platos =======
  Widget _dishCard(Map<String, dynamic> d) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 11,
              child: Image.network(d['img'], fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              d['name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textMain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Text(
              '\$${(d['price'] as num).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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

  // ======= Carrusel promos con assets =======
  Widget _promoCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _promoCtrl,
        onPageChanged: (i) => setState(() => _promoIndex = i),
        itemCount: promoImages.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(promoImages[i], fit: BoxFit.cover),
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

  // Bottom nav
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home_rounded, true),
          _navItem(Icons.local_offer_outlined, false),
          _navItem(Icons.menu_book_outlined, false),
          _navItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool active) {
    return InkResponse(
      child: Icon(
        icon,
        size: 28,
        color: active ? Colors.black87 : Colors.black45,
      ),
    );
  }
}

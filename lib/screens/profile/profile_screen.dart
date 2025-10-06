// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Estilos
  static const bg = Color(0xFFFFFFFF);
  static const textMain = Colors.black87;
  static const textTitle = Colors.black;
  static const sep = Color(0x11000000);

  int _tab = 3; // Perfil activo (0 home, 1 promos, 2 pedidos, 3 perfil)

  // Helpers SVG (usa la ruta correcta según tu pubspec: assets/icon/)
  String _iconPath(String name) => 'assets/icon/$name.svg';

  Widget _svg(String asset, {double size = 24, Color? color}) => SvgPicture.asset(
    asset,
    width: size,
    height: size,
    colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );

  Future<String> _loadUserName() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return 'Usuario';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
      final data = doc.data();
      final nombre = (data?['nombre'] ?? '').toString().trim();
      final apellido = (data?['apellido'] ?? '').toString().trim();
      final full = [nombre, apellido].where((e) => e.isNotEmpty).join(' ');
      return full.isNotEmpty ? full : (u.displayName ?? 'Usuario');
    } catch (_) {
      return u.displayName ?? 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: _bottomBar(context),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _loadUserName(),
          builder: (context, snap) {
            final name = snap.data ?? 'Usuario';
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: _svg(_iconPath('back'), size: 22, color: Colors.black87),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: _svg(_iconPath('cart'), size: 22, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '¡Hola, $name!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: textTitle,
                  ),
                ),
                const SizedBox(height: 18),

                // Accesos rápidos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _quickAction(
                      icon: _iconPath('perfil'),
                      label: 'Información\npersonal',
                      onTap: () => _todo(context, 'Información personal'),
                    ),
                    _quickAction(
                      icon: _iconPath('promociones'),
                      label: 'Descuentos',
                      onTap: () => _todo(context, 'Descuentos'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _sectionTitle('Perfil'),
                _settingTile(
                  icon: _iconPath('ubicacion'),
                  title: 'Dirección',
                  onTap: () => _todo(context, 'Dirección'),
                ),
                _settingTile(
                  icon: _iconPath('hearth'),
                  title: 'Favoritos',
                  onTap: () => _todo(context, 'Favoritos'),
                ),

                const SizedBox(height: 20),
                _sectionTitle('Configuración'),
                _settingTile(
                  icon: _iconPath('bell'),
                  title: 'Notificaciones',
                  onTap: () => _todo(context, 'Notificaciones'),
                ),
                _settingTile(
                  icon: _iconPath('info'),
                  title: 'Información legal',
                  onTap: () => _todo(context, 'Información legal'),
                ),

                const SizedBox(height: 24),
                const Divider(color: sep),
                const SizedBox(height: 10),

                // Cerrar sesión
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _signOut,
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ====== Widgets reutilizables ======

  Widget _quickAction({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            _svg(icon, size: 42, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: textTitle,
        ),
      ),
    );
  }

  Widget _settingTile({
    required String icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _svg(icon, size: 24, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: textMain,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black45),
      onTap: onTap,
    );
  }

  // ====== Bottom bar con SVG ======

  Widget _bottomBar(BuildContext context) {
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
          children: [
            _navItem('home', 0, onTap: () {
              if (_tab != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            }),
            _navItem('promociones', 1, onTap: () => _todo(context, 'Promociones')),
            _navItem('hoja', 2, onTap: () => _todo(context, 'Pedidos')),
            _navItem('perfil', 3, onTap: () {}), // ya estás aquí
          ],
        ),
      ),
    );
  }

  Widget _navItem(String name, int index, {required VoidCallback onTap}) {
    final active = _tab == index;
    return InkResponse(
      onTap: onTap,
      child: _svg(
        _iconPath(name),
        size: 28,
        color: active ? Colors.black87 : Colors.black45,
      ),
    );
  }

  // ====== Acciones ======

  void _todo(BuildContext context, String where) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$where (pendiente)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    // Vuelve a la raíz; AuthGate debería mostrar el login automáticamente
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

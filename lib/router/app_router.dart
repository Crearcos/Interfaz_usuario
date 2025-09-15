import 'package:flutter/material.dart';
import '../features/auth/auth_options_page.dart';
import '../features/home/home_page.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    '/auth': (_) => const AuthChoicePage(),
    '/home': (_) => const HomePage(),
  };
}

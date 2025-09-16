import 'package:flutter/material.dart';

// Features
import '../features/auth/auth_options_page.dart';
import '../features/home/home_page.dart';

// Phone
import '../pages/login_phone_page.dart';
import '../pages/otp_code_page.dart';

// Email
import '../pages/login_email_page.dart';
import '../pages/login_password_page.dart';
import '../pages/register_page.dart';

// NUEVAS: flujo de onboarding post-registro
import '../pages/location_permission_page.dart';
import '../pages/address_page.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    '/auth':            (_) => const AuthChoicePage(),
    '/phone':           (_) => const LoginPhonePage(),
    '/otp':             (_) => const OtpCodePage(),
    '/home':            (_) => const HomePage(),

    '/login-email':     (_) => const LoginEmailPage(),
    '/login-password':  (_) => const LoginPasswordPage(),
    '/register':        (_) => const RegisterPage(),

    // nuevas
    '/loc-permission':  (_) => const LocationPermissionPage(),
    '/address':         (_) => const AddressPage(),
  };
}

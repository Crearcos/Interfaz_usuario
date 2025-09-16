import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'features/auth/phone_auth_controller.dart';

Future<void> main() async {
  final wb = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: wb);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Idioma de los mensajes (elige una)
  await FirebaseAuth.instance.setLanguageCode('es');
  // o:
  // FirebaseAuth.instance.useDeviceLanguage();

  // Solo para pruebas locales con NÚMEROS DE PRUEBA de Firebase
  if (!kReleaseMode) {
    await FirebaseAuth.instance
        .setSettings(appVerificationDisabledForTesting: true);
  }

  FlutterNativeSplash.remove(); // no necesitas el delay artificial
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhoneAuthController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/auth',        // asegúrate que exista en AppRouter.routes
        routes: AppRouter.routes,     // y que /auth apunte a tu pantalla de login por teléfono
      ),
    );
  }
}

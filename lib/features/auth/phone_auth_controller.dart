import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PhoneAuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? error;

  String? _verificationId;
  int? _resendToken;

  // Getters útiles para la UI
  String? get verificationId => _verificationId;
  int? get resendToken => _resendToken;
  bool get hasVerificationId => _verificationId != null && _verificationId!.isNotEmpty;
  bool get isCodeSent => hasVerificationId;

  void clearError() {
    error = null;
    notifyListeners();
  }

  /// Envía el código por SMS. Devuelve true si todo salió bien.
  Future<bool> sendCode(String e164Phone, {int? forceResendToken}) async {
    isLoading = true;
    error = null;
    _verificationId = null; // resetea para evitar estados viejos
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: e164Phone, // Debe venir en formato E.164 (+593...)
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendToken,
        verificationCompleted: (PhoneAuthCredential cred) async {
          // Verificación instantánea / auto-retrieval: intenta login automático
          try {
            await _auth.signInWithCredential(cred);
          } catch (e) {
            error = 'No se pudo ingresar automáticamente. Intenta con el código.';
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          error = _mapFriendlyMessage(e);
        },
        codeSent: (String verId, int? rToken) {
          _verificationId = verId;
          _resendToken = rToken;
        },
        codeAutoRetrievalTimeout: (String verId) {
          // No es error, solo que no se auto-recuperó el SMS
          _verificationId = verId;
        },
      );
    } catch (e) {
      error = 'Error al solicitar el código. ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return error == null && hasVerificationId;
  }

  /// Confirma el código ingresado por el usuario.
  Future<UserCredential> confirmCode(String smsCode) async {
    if (!hasVerificationId) {
      throw StateError('No hay verificationId. Primero solicita el código.');
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(cred);
      return result;
    } on FirebaseAuthException catch (e) {
      error = _mapFriendlyMessage(e);
      rethrow; // útil si la UI quiere capturar para analytics; igual queda `error` seteado
    } catch (e) {
      error = 'No se pudo verificar el código. ${e.toString()}';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Opcional, por si quieres cerrar sesión desde el controller
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
    notifyListeners();
  }

  String _mapFriendlyMessage(FirebaseAuthException e) {
    // e.code viene en inglés; lo traducimos a algo más claro
    switch (e.code) {
      case 'invalid-phone-number':
        return 'El número es inválido. Usa formato +5939XXXXXXXX.';
      case 'missing-phone-number':
        return 'Falta el número de teléfono.';
      case 'invalid-verification-code':
        return 'El código de verificación es inválido.';
      case 'session-expired':
      case 'code-expired':
        return 'El código expiró. Solicita uno nuevo.';
      case 'quota-exceeded':
      case 'too-many-requests':
        return 'Se excedió la cuota o hay muchos intentos. Prueba más tarde.';
      case 'captcha-check-failed':
        return 'Fallo en la verificación de seguridad. Inténtalo otra vez.';
      case 'app-not-authorized':
        return 'La app no está autorizada para usar este proyecto de Firebase.';
      default:
        return e.message ?? 'Error de verificación. (${e.code})';
    }
  }
}

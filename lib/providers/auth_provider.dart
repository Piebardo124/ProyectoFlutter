import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_flutter/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  //Inicio de sesion
  Future<bool> signInWithEmail(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    final user = await _authService.signInWithEmailAndPassword(
      email,
      password,
      context,
    );
    _setLoading(false);
    return user != null;
  }

  // Registro
  Future<bool> registerWithEmail(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    final user = await _authService.registerWithEmailAndPassword(
      email,
      password,
      context,
    );
    _setLoading(false);
    return user != null;
  }

  // Email de recuperacion
  Future<void> sendPasswordResetEmail(
    String email,
    BuildContext context,
  ) async {
    _setLoading(true);
    await _authService.sendPasswordResetEmail(email, context);
    _setLoading(false);
  }

  // Cerrar Sesion
  Future<void> signOut() async {
    await _authService.signOut();
  }

  //Estado de cuenta
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

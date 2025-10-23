import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Importa las pantallas a las que vamos a redirigir
import 'package:proyecto_flutter/screens/auth/login_screen.dart';
// import 'package:proyecto_flutter/screens/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Llama a nuestra función de verificación después de que la pantalla se construya
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Un pequeño retraso para que tu logo se muestre (opcional)
    await Future.delayed(const Duration(seconds: 2));

    // Comprueba si el widget sigue "montado" (visible) antes de navegar
    if (!mounted) return;

    // Escucha el estado de autenticación de Firebase
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // No hay usuario logueado -> Ir a LoginScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Esta es la pantalla de carga que el usuario ve
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood, // El mismo logo de hamburguesa
              size: 100,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Cargando...'),
          ],
        ),
      ),
    );
  }
}

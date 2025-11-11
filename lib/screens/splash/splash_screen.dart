import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_flutter/screens/auth/login_screen.dart';
//import 'package:proyecto_flutter/screens/home_placeholder.dart';
import 'package:proyecto_flutter/screens/main_navigation_screen.dart';
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
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Verificar estado de autentificacion
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return;

      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
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
              Icons.fastfood, //Icono de hambugueas
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

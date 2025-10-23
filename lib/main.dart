import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Importa tu nueva pantalla de carga
import 'package:proyecto_flutter/screens/splash/splash_screen.dart'; // <-- Ajusta esta ruta

void main() async {
  // Esto ya lo tenías, está perfecto
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BurgerApp', // Puedes cambiar el título
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Aquí está el cambio:
      // Inicia en la pantalla de carga, no en la de login directamente.
      home: const SplashScreen(),
    );
  }
}

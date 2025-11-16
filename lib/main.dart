import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_flutter/providers/auth_provider.dart';
import 'package:proyecto_flutter/providers/cart_provider.dart';
import 'package:proyecto_flutter/providers/products_provider.dart';
import 'package:proyecto_flutter/screens/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema Tecnico
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,

      // Esquema de color (Plata)
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey[200]!,
        primary: Colors.blueGrey[300]!,
        brightness: Brightness.light,
      ),

      // AppBar (Plata)
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blueGrey[200]!,
        foregroundColor: Colors.black,
      ),

      // Botones (Rojo de El Santo)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
        ),
      ),
    );

    // Tema rudo
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[900],

      // Esquema de color (Azul Demon)
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue[800]!,
        primary: Colors.blue[700]!,
        brightness: Brightness.dark,
      ),

      // AppBar (Azul Demon)
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue[800]!,
        foregroundColor: Colors.white,
      ),

      // Botones (Rosa "Villanos")
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent[400],
          foregroundColor: Colors.black,
        ),
      ),
    );

    return MaterialApp(
      title: 'RING BURGER',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

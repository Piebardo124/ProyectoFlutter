import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/providers/auth_provider.dart';
import 'package:proyecto_flutter/screens/auth/login_screen.dart';

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha al AuthProvider para cerrar sesión
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Principal (Temporal)'),
        actions: [
          // --- Botón para Cerrar Sesión ---
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();

              // Navegar de vuelta al Login y borrar todo lo anterior
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Inicio de sesión exitoso!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

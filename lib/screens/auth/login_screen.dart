import 'package:flutter/material.dart';
import 'package:proyecto_flutter/services/auth_service.dart';

import 'package:proyecto_flutter/screens/auth/register_screen.dart';
import 'package:proyecto_flutter/screens/auth/forgot_password_screen.dart';
//import 'package:proyecto_flutter/screens/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para el texto de email y contraseña
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _signIn() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Llamar al servicio de autenticación
    final user = await _authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      context, // Pasamos el context para mostrar SnackBars de error
    );

    setState(() {
      _isLoading = false;
    });

    // Si user es null, el auth_service ya mostró el error
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              //mainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo de tu app (Ej. una hamburguesa)
                const Icon(
                  Icons.fastfood, // Puedes cambiar esto por tu logo
                  size: 100,
                  color: Colors.amber, // Color de tu marca
                ),
                const SizedBox(height: 20),
                Text(
                  'BurgerApp', // Nombre de tu restaurante
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 40),

                // --- Campo de Email ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Favor de ingresar un Email Valido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Campo de Contraseña ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Oculta la contraseña
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Contraseña debe de contar con mas de 6 digitos.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // --- Botón de Inicio de Sesión ---
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple, // Color principal de tu app
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _signIn,
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 20),

                // --- Links a Registro y Olvido de Contraseña ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navegar a la pantalla de registro
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const RegisterScreen(), // Asegúrate de crear este archivo
                          ),
                        );
                      },
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navegar a la pantalla de olvido de contraseña
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordScreen(), // Asegúrate de crear este archivo
                          ),
                        );
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

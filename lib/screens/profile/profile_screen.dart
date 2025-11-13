import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/models/user_model.dart';
import 'package:proyecto_flutter/providers/auth_provider.dart';
import 'package:proyecto_flutter/services/firestore_service.dart';
import 'package:proyecto_flutter/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final firestoreService = FirestoreService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se pudo cargar el usuario.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: FutureBuilder<UserModel?>(
        future: firestoreService.getUserData(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No se encontraron datos del perfil.'),
            );
          }

          final userModel = snapshot.data!;

          // Mostramos la información del usuario
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(height: 24),

                // Informacion del perfil
                _buildProfileTile(
                  icon: Icons.person_outline,
                  title: 'Nombre',
                  // Mostramos el email si el nombre está vacío
                  subtitle: userModel.displayName.isEmpty
                      ? '(Sin nombre)'
                      : userModel.displayName,
                  onTap: () {
                    // Aquí podrías navegar a una pantalla para editar el nombre
                  },
                ),
                _buildProfileTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: userModel.email,
                ),
                _buildProfileTile(
                  icon: Icons.phone_outlined,
                  title: 'Teléfono',
                  subtitle: userModel.phone.isEmpty
                      ? '(Añadir teléfono)'
                      : userModel.phone,
                  onTap: () {
                    // Aquí podrías navegar a una pantalla para editar el teléfono
                  },
                ),
                _buildProfileTile(
                  icon: Icons.location_on_outlined,
                  title: 'Dirección',
                  subtitle: userModel.address.isEmpty
                      ? '(Añadir dirección)'
                      : userModel.address,
                  onTap: () {
                    // Aquí podrías navegar a una pantalla para editar la dirección
                  },
                ),

                const Divider(height: 40),

                // Botton de cierre de sesion
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    await authProvider.signOut();

                    if (context.mounted) {
                      // Regresar al Login y borrar el historial
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      trailing: onTap != null
          ? const Icon(Icons.edit_outlined, size: 18)
          : null,
      onTap: onTap,
    );
  }
}

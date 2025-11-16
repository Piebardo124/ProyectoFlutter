import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/models/user_model.dart';
import 'package:proyecto_flutter/providers/auth_provider.dart';
import 'package:proyecto_flutter/services/firestore_service.dart';
import 'package:proyecto_flutter/screens/auth/login_screen.dart';
import 'package:proyecto_flutter/screens/profile/edit_address_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState2();
}

class _ProfileScreenState2 extends State<ProfileScreen> {
  final FirestoreService firestoreService = FirestoreService();
  late Future<UserModel?> _userFuture;
  String? _userId;

  @override
  void initState() {
    super.initState();

    _userId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    _loadUserData();
  }

  void _loadUserData() {
    if (_userId != null) {
      setState(() {
        _userFuture = firestoreService.getUserData(_userId!);
      });
    }
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    UserModel currentUser,
  ) async {
    final nameController = TextEditingController(text: currentUser.displayName);

    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Actualizar Nombre'),
          content: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) return;

                try {
                  await firestoreService.updateUserData(_userId!, {
                    'displayName': newName,
                  });
                  Navigator.of(ctx).pop();
                  _loadUserData();
                } catch (e) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditPhoneDialog(
    BuildContext context,
    UserModel currentUser,
  ) async {
    final phoneController = TextEditingController(text: currentUser.phone);
    final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Actualizar Teléfono'),
          content: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(labelText: 'Teléfono'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final newPhone = phoneController.text.trim();
                try {
                  await firestoreService.updateUserData(_userId!, {
                    'phone': newPhone,
                  });
                  Navigator.of(ctx).pop();
                  _loadUserData();
                } catch (e) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se pudo cargar el usuario.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
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

          String displayAddress;
          if (userModel.calle.isEmpty) {
            displayAddress = '(Añadir dirección)';
          } else {
            String numero = userModel.numInt.isNotEmpty
                ? userModel.numInt
                : userModel.numExt;
            displayAddress = '${userModel.calle} $numero';
          }

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
                _buildProfileTile(
                  icon: Icons.person_outline,
                  title: 'Nombre',
                  subtitle: userModel.displayName.isEmpty
                      ? '(Sin nombre)'
                      : userModel.displayName,
                  onTap: () {
                    _showEditNameDialog(context, userModel);
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
                    _showEditPhoneDialog(context, userModel);
                  },
                ),
                _buildProfileTile(
                  icon: Icons.location_on_outlined,
                  title: 'Dirección',
                  subtitle: displayAddress,
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => EditAddressScreen(
                              currentUser: userModel,
                              userId: _userId!,
                            ),
                          ),
                        )
                        .then((_) {
                          _loadUserData();
                        });
                  },
                ),
                const Divider(height: 40),
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

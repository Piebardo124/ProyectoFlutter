import 'package:flutter/material.dart';
import 'package:proyecto_flutter/models/user_model.dart';
import 'package:proyecto_flutter/services/firestore_service.dart';

class EditAddressScreen extends StatefulWidget {
  final UserModel currentUser;
  final String userId;

  const EditAddressScreen({
    super.key,
    required this.currentUser,
    required this.userId,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  late TextEditingController _calleController;
  late TextEditingController _numExtController;
  late TextEditingController _numIntController;
  late TextEditingController _coloniaController;
  late TextEditingController _ciudadController;
  late TextEditingController _estadoController;

  @override
  void initState() {
    super.initState();
    _calleController = TextEditingController(text: widget.currentUser.calle);
    _numExtController = TextEditingController(text: widget.currentUser.numExt);
    _numIntController = TextEditingController(text: widget.currentUser.numInt);
    _coloniaController = TextEditingController(
      text: widget.currentUser.colonia,
    );
    _ciudadController = TextEditingController(text: widget.currentUser.ciudad);
    _estadoController = TextEditingController(text: widget.currentUser.estado);
  }

  @override
  void dispose() {
    _calleController.dispose();
    _numExtController.dispose();
    _numIntController.dispose();
    _coloniaController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> addressData = {
        'calle': _calleController.text.trim(),
        'numExt': _numExtController.text.trim(),
        'numInt': _numIntController.text.trim(),
        'colonia': _coloniaController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
        'estado': _estadoController.text.trim(),
      };

      await _firestoreService.updateUserData(widget.userId, addressData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirección actualizada'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Dirección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_calleController, 'Dirección (Calle)'),
              _buildTextField(_numExtController, 'Número Exterior'),
              _buildTextField(
                _numIntController,
                'Número Interior (Opcional)',
                isOptional: true,
              ),
              _buildTextField(_coloniaController, 'Colonia'),
              _buildTextField(_ciudadController, 'Ciudad'),
              _buildTextField(_estadoController, 'Estado'),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _saveAddress,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Dirección',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Este campo es requerido';
          }
          return null;
        },
      ),
    );
  }
}

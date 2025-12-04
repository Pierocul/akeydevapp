import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? 'Julián Gómez Palacios';
    _emailController.text = user?.email ?? 'juliangomezp@udd.cl';
    _phoneController.text = '9 8186 8587';
    _addressController.text = 'Mardoñal 8722';
    _birthDateController.text = '02/11/2003';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _changeProfilePicture() async {
    // Simulación - solo mostrar mensaje
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidad de cambio de foto próximamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pinkColor = colorScheme.primary;
    final purpleColor = const Color(0xFF3605EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: purpleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mi perfil',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Foto de perfil
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: const AssetImage('assets/img/julian.jpg'),
                    onBackgroundImageError: (_, __) {},
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _changeProfilePicture,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: pinkColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Texto "Cambiar foto de perfil"
              GestureDetector(
                onTap: _changeProfilePicture,
                child: Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Campo: Nombre completo
              _buildTextField(
                label: 'Nombre completo',
                controller: _nameController,
                pinkColor: pinkColor,
              ),

              const SizedBox(height: 24),

              // Campo: Correo electrónico
              _buildTextField(
                label: 'Correo electrónico',
                controller: _emailController,
                pinkColor: pinkColor,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              // Campo: Número telefónico
              _buildTextField(
                label: 'Número telefónico',
                controller: _phoneController,
                pinkColor: pinkColor,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // Campo: Dirección
              _buildTextField(
                label: 'Dirección',
                controller: _addressController,
                pinkColor: pinkColor,
              ),

              const SizedBox(height: 24),

              // Campo: Fecha de nacimiento
              _buildTextField(
                label: 'Fecha de nacimiento',
                controller: _birthDateController,
                pinkColor: pinkColor,
                readOnly: true,
                onTap: () {
                  // Simulación - solo mostrar mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selector de fecha próximamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Botón guardar (opcional, solo simulación)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Simulación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil actualizado (simulación)'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: pinkColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Color pinkColor,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: pinkColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}


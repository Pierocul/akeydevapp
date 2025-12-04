import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';
import '../models/property.dart';
import 'edit_property_dialog.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.fs});

  final FirestoreService fs;

  Future<void> _showAddPropertyDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => _AddPropertyDialog(fs: fs),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => _EditProfileDialog(),
    );
  }

  static Future<void> showEditPropertyDialog(
    BuildContext context,
    Property property,
    FirestoreService fs,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => EditPropertyDialog(
        property: property,
        fs: fs,
      ),
    );
  }

  static Future<void> showDeletePropertyDialog(
    BuildContext context,
    Property property,
    FirestoreService fs,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eliminar propiedad'),
        content: Text('¿Estás seguro de que deseas eliminar "${property.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await fs.deleteProperty(property.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Propiedad eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    // Obtener información del usuario
    final displayName = user?.displayName ?? 'Usuario';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showEditProfileDialog(context),
            child: _ProfileAvatar(
              colorScheme: colorScheme,
              photoUrl: photoUrl,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          if (email.isNotEmpty)
            Text(
              email,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          const SizedBox(height: 24),
          _ProfileOptionsCard(colorScheme: colorScheme, textTheme: textTheme),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _showAddPropertyDialog(context),
            icon: const Icon(Icons.add_home_outlined),
            label: const Text(
              'Agregar propiedad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () async {
              // Cerrar sesión de Firebase
              await FirebaseAuth.instance.signOut();
              // Cerrar sesión de Google
              await GoogleSignIn().signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesión cerrada'),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.logout,
              color: colorScheme.primary,
            ),
            label: Text(
              'Cerrar sesión',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'ID: ${user.uid.substring(0, 8)}…',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.colorScheme,
    this.photoUrl,
  });

  final ColorScheme colorScheme;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? Image.network(
                    photoUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  )
                : Image.asset(
                    'assets/img/julian.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: 6,
          right: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.camera_alt_rounded,
                color: colorScheme.onPrimary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileOptionsCard extends StatelessWidget {
  const _ProfileOptionsCard({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final options = [
      (Icons.person_outline, 'Perfil', () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
      }),
      (Icons.bookmark_border, 'Favoritos', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favoritos próximamente')),
        );
      }),
      (Icons.settings_outlined, 'Configuración', () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
      }),
      (Icons.credit_card_outlined, 'Métodos de pago', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Métodos de pago próximamente')),
        );
      }),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: options
              .map(
                (option) => ListTile(
                  leading: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        option.$1,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    option.$2,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  onTap: option.$3,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _AddPropertyDialog extends StatefulWidget {
  const _AddPropertyDialog({required this.fs});

  final FirestoreService fs;

  @override
  State<_AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<_AddPropertyDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Formularios
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // Controladores
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Estado
  File? _pickedImageFile;
  final _picker = ImagePicker();
  bool _isLoadingCoordinates = false;
  double? _latitude;
  double? _longitude;
  String? _coordinateError;

  // Características disponibles
  final List<String> _availableFeatures = [
    'Aire acondicionado',
    'Estacionamiento',
    'Piscina',
    'Gimnasio',
    'Seguridad 24/7',
    'Jardín',
    'Terraza',
    'Balcón',
    'Cocina equipada',
    'Lavandería',
  ];
  final Set<String> _selectedFeatures = {};

  // 1. Selecciona imagen del dispositivo
  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90, // Alta calidad para evitar pixelación
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
    }
  }

  // 2. Sube la imagen a Firebase Storage y retorna la URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      if (kDebugMode) {
        print('=== INICIANDO SUBIDA DE IMAGEN ===');
        print('Ruta del archivo: ${imageFile.path}');
        print('Archivo existe: ${await imageFile.exists()}');
        print('Tamaño del archivo: ${await imageFile.length()} bytes');
      }

      // Verificar que el usuario esté autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('ERROR: No hay usuario autenticado');
        }
        return null;
      }
      if (kDebugMode) {
        print('Usuario autenticado: ${user.uid}');
      }

      // Crear referencia de Storage
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'property_$timestamp.jpg';
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('property_images')
          .child(fileName);

      if (kDebugMode) {
        print('Referencia de Storage: ${storageRef.fullPath}');
        print('Bucket: ${FirebaseStorage.instance.app.options.storageBucket}');
      }

      // Subir el archivo
      if (kDebugMode) {
        print('Iniciando uploadTask...');
      }
      
      final uploadTask = storageRef.putFile(imageFile);
      
      // Monitorear el progreso
      uploadTask.snapshotEvents.listen((snapshot) {
        if (kDebugMode) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Progreso: ${progress.toStringAsFixed(1)}%');
        }
      });
      
      // Esperar a que la subida se complete
      if (kDebugMode) {
        print('Esperando que se complete la subida...');
      }
      final snapshot = await uploadTask;
      
      if (kDebugMode) {
        print('Subida completada. Estado: ${snapshot.state}');
        print('Bytes transferidos: ${snapshot.bytesTransferred}');
      }
      
      // Obtener la URL de descarga
      if (kDebugMode) {
        print('Obteniendo URL de descarga...');
      }
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('URL obtenida exitosamente: $downloadUrl');
        print('=== SUBIDA COMPLETADA ===');
      }

      return downloadUrl;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('=== ERROR AL SUBIR IMAGEN ===');
        print('Error: $error');
        print('Tipo de error: ${error.runtimeType}');
        print('Stack trace: $stackTrace');
        
        // Información adicional según el tipo de error
        if (error.toString().contains('permission')) {
          print('PROBLEMA: Error de permisos. Verifica las reglas de Storage en Firebase Console');
        } else if (error.toString().contains('network')) {
          print('PROBLEMA: Error de red. Verifica tu conexión a internet');
        } else if (error.toString().contains('unauthorized')) {
          print('PROBLEMA: No autorizado. Verifica que el usuario esté autenticado');
        }
        print('=== FIN DEL ERROR ===');
      }
      return null;
    }
  }

  Future<void> _getCoordinatesFromAddress() async {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      if (mounted) {
        setState(() {
          _coordinateError = 'Ingresa una dirección primero';
          _latitude = null;
          _longitude = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingCoordinates = true;
        _coordinateError = null;
      });
    }

    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        if (mounted) {
          setState(() {
            _latitude = locations.first.latitude;
            _longitude = locations.first.longitude;
            _coordinateError = null;
          });
        } else {
          // Si el widget no está montado, solo actualizar las variables
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
          _coordinateError = null;
        }
      } else {
        if (mounted) {
          setState(() {
            _coordinateError = 'No se encontró la ubicación';
            _latitude = null;
            _longitude = null;
          });
        } else {
          _coordinateError = 'No se encontró la ubicación';
          _latitude = null;
          _longitude = null;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _coordinateError = 'Error al buscar ubicación: ${e.toString()}';
          _latitude = null;
          _longitude = null;
        });
      } else {
        _coordinateError = 'Error al buscar ubicación: ${e.toString()}';
        _latitude = null;
        _longitude = null;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCoordinates = false;
        });
      } else {
        _isLoadingCoordinates = false;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _areaCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pickedImageFile = null;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Paso 1: Información básica
        if (!_formKeyStep1.currentState!.validate()) return false;
        if (_pickedImageFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecciona una imagen')),
          );
          return false;
        }
        return true;
      case 1: // Paso 2: Detalles
        if (!_formKeyStep2.currentState!.validate()) return false;
        return true;
      case 2: // Paso 3: Descripción (opcional)
        return true;
      case 3: // Paso 4: Características (opcional)
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pinkColor = colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con indicador de progreso
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Agregar propiedad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Indicador de pasos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _totalSteps,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentStep >= index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentStep >= index
                                    ? pinkColor
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Espacio para balancear el close button
                ],
              ),
            ),
            const Divider(height: 1),
            // Contenido del wizard
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildStep1(colorScheme),
                  _buildStep2(colorScheme),
                  _buildStep3(colorScheme),
                  _buildStep4(colorScheme),
                ],
              ),
            ),
            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child: const Text('Atrás'),
                    )
                  else
                    const SizedBox.shrink(),
                  FilledButton(
                    onPressed: () async {
                      if (!_validateCurrentStep()) return;

                      if (_currentStep < _totalSteps - 1) {
                        _nextStep();
                      } else {
                        await _saveProperty(context);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: pinkColor,
                    ),
                    child: Text(_currentStep < _totalSteps - 1 ? 'Siguiente' : 'Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información básica',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Selector de imagen
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 2),
                  ),
                  child: _pickedImageFile != null
                      ? ClipOval(
                          child: Image.file(
                            _pickedImageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca para\nseleccionar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la propiedad *',
                hintText: 'Ej. Condominio Reina Bernstein',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: 'Dirección *',
                hintText: 'Ej. Av. Providencia 123, Santiago',
                suffixIcon: _isLoadingCoordinates
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _getCoordinatesFromAddress,
                        tooltip: 'Buscar ubicación',
                      ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa la dirección';
                }
                return null;
              },
              onFieldSubmitted: (_) => _getCoordinatesFromAddress(),
            ),
            if (_coordinateError != null) ...[
              const SizedBox(height: 8),
              Text(
                _coordinateError!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ],
            if (_latitude != null && _longitude != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ubicación encontrada',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Precio (opcional)',
                hintText: 'Ej. UF 33.200',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles de la propiedad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Habitaciones *',
                      hintText: 'Ej. 3',
                      prefixIcon: Icon(Icons.bed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Baños *',
                      hintText: 'Ej. 2',
                      prefixIcon: Icon(Icons.bathtub),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaCtrl,
              decoration: const InputDecoration(
                labelText: 'Área (m²) *',
                hintText: 'Ej. 120',
                prefixIcon: Icon(Icons.square_foot),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Requerido';
                }
                final num = double.tryParse(value);
                if (num == null || num <= 0) {
                  return 'Número inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descripción',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Describe la propiedad (opcional)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _descriptionCtrl,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText:
                  'Ej. Este condominio se caracteriza por la amplitud de sus unidades...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Características',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona las características de la propiedad (opcional)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ..._availableFeatures.map((feature) => CheckboxListTile(
                title: Text(feature),
                value: _selectedFeatures.contains(feature),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedFeatures.add(feature);
                    } else {
                      _selectedFeatures.remove(feature);
                    }
                  });
                },
                activeColor: colorScheme.primary,
              )),
        ],
      ),
    );
  }

  Future<void> _saveProperty(BuildContext context) async {
    // Obtener coordenadas ANTES de cerrar el diálogo (si no se tienen)
    if (_latitude == null || _longitude == null) {
      final address = _addressCtrl.text.trim();
      if (address.isNotEmpty && mounted) {
        try {
          // Actualizar UI para mostrar que se está buscando
          setState(() {
            _isLoadingCoordinates = true;
          });
          
          final locations = await locationFromAddress(address);
          if (locations.isNotEmpty && mounted) {
            setState(() {
              _latitude = locations.first.latitude;
              _longitude = locations.first.longitude;
              _isLoadingCoordinates = false;
            });
          } else if (mounted) {
            setState(() {
              _isLoadingCoordinates = false;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error al obtener coordenadas: $e');
          }
          if (mounted) {
            setState(() {
              _isLoadingCoordinates = false;
            });
          }
          // Continuar sin coordenadas
        }
      }
    }

    // Cerrar el diálogo después de obtener coordenadas
    if (!context.mounted) return;
    Navigator.of(context).pop();

    final messenger = ScaffoldMessenger.of(context);

    // Mostrar indicador de carga
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Subiendo imagen y guardando propiedad...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      // Verificar autenticación
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (context.mounted) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Error: No estás autenticado. Reinicia la app.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Subir imagen
      final uploadedUrl = await _uploadImage(_pickedImageFile!);
      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        if (context.mounted) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Error al subir la imagen.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Guardar propiedad
      if (kDebugMode) {
        print('=== GUARDANDO PROPIEDAD ===');
        print('Nombre: ${_nameCtrl.text.trim()}');
        print('Dirección: ${_addressCtrl.text.trim()}');
        print('Imagen URL: $uploadedUrl');
        print('Habitaciones: ${int.tryParse(_bedroomsCtrl.text.trim()) ?? 0}');
        print('Baños: ${int.tryParse(_bathroomsCtrl.text.trim()) ?? 0}');
        print('Área: ${double.tryParse(_areaCtrl.text.trim()) ?? 0.0}');
        print('Características: ${_selectedFeatures.toList()}');
        print('Coordenadas: $_latitude, $_longitude');
      }

      await widget.fs.addProperty(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        imageUrl: uploadedUrl,
        price: _priceCtrl.text.trim(),
        bedrooms: int.tryParse(_bedroomsCtrl.text.trim()) ?? 0,
        bathrooms: int.tryParse(_bathroomsCtrl.text.trim()) ?? 0,
        area: double.tryParse(_areaCtrl.text.trim()) ?? 0.0,
        description: _descriptionCtrl.text.trim(),
        features: _selectedFeatures.toList(),
        latitude: _latitude,
        longitude: _longitude,
      );

      if (kDebugMode) {
        print('✓ Propiedad guardada exitosamente en Firestore');
      }

      if (context.mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Propiedad agregada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('=== ERROR AL GUARDAR PROPIEDAD ===');
        print('Error: $e');
        print('Tipo: ${e.runtimeType}');
        print('Stack trace: $stackTrace');
      }
      if (context.mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error al guardar la propiedad',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }
}

// Diálogo para editar perfil
class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog();

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  File? _pickedImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUser.uid}_$timestamp.jpg');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen de perfil: $e');
      }
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      String? photoUrl = user.photoURL;

      // Subir nueva imagen si se seleccionó una
      if (_pickedImageFile != null) {
        final uploadedUrl = await _uploadProfileImage(_pickedImageFile!);
        if (uploadedUrl != null) {
          photoUrl = uploadedUrl;
        }
      }

      // Actualizar perfil en Firebase Auth
      await user.updateDisplayName(_nameController.text.trim());
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
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
    final user = FirebaseAuth.instance.currentUser;
    final currentPhotoUrl = user?.photoURL;
    
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Foto de perfil
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _pickedImageFile != null
                        ? FileImage(_pickedImageFile!)
                        : (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty
                            ? NetworkImage(currentPhotoUrl)
                            : null),
                    child: _pickedImageFile == null && 
                           (currentPhotoUrl == null || currentPhotoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}


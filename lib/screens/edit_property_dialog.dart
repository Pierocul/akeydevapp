import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';
import '../services/firestore_service.dart';

class EditPropertyDialog extends StatefulWidget {
  const EditPropertyDialog({
    super.key,
    required this.property,
    required this.fs,
  });

  final Property property;
  final FirestoreService fs;

  @override
  State<EditPropertyDialog> createState() => _EditPropertyDialogState();
}

class _EditPropertyDialogState extends State<EditPropertyDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _bedroomsCtrl;
  late final TextEditingController _bathroomsCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _descriptionCtrl;

  File? _pickedImageFile;
  final _picker = ImagePicker();
  bool _isLoadingCoordinates = false;
  double? _latitude;
  double? _longitude;
  String? _coordinateError;
  List<String> _selectedFeatures = [];
  String? _currentImageUrl;

  static const List<String> _availableFeatures = [
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

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.property.name);
    _addressCtrl = TextEditingController(text: widget.property.address);
    _priceCtrl = TextEditingController(text: widget.property.price);
    _bedroomsCtrl = TextEditingController(text: widget.property.bedrooms.toString());
    _bathroomsCtrl = TextEditingController(text: widget.property.bathrooms.toString());
    _areaCtrl = TextEditingController(text: widget.property.area.toString());
    _descriptionCtrl = TextEditingController(text: widget.property.description);
    _selectedFeatures = List<String>.from(widget.property.features);
    _latitude = widget.property.latitude;
    _longitude = widget.property.longitude;
    _currentImageUrl = widget.property.imageUrl;
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
      case 0:
        if (!_formKeyStep1.currentState!.validate()) return false;
        if (_pickedImageFile == null && _currentImageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecciona una imagen')),
          );
          return false;
        }
        return true;
      case 1:
        return _formKeyStep2.currentState!.validate();
      default:
        return true;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
          _currentImageUrl = null;
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

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('property_images')
          .child('property_$timestamp.jpg');

      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen: $e');
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
        }
      } else {
        if (mounted) {
          setState(() {
            _coordinateError = 'No se encontró la ubicación';
            _latitude = null;
            _longitude = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _coordinateError = 'Error al buscar ubicación: ${e.toString()}';
          _latitude = null;
          _longitude = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCoordinates = false;
        });
      }
    }
  }

  Future<void> _saveProperty(BuildContext context) async {
    if (_latitude == null || _longitude == null) {
      final address = _addressCtrl.text.trim();
      if (address.isNotEmpty && mounted) {
        try {
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
          if (mounted) {
            setState(() {
              _isLoadingCoordinates = false;
            });
          }
        }
      }
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();

    final messenger = ScaffoldMessenger.of(context);

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
            Text('Guardando cambios...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
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

      String imageUrl = _currentImageUrl ?? widget.property.imageUrl;
      if (_pickedImageFile != null) {
        final uploadedUrl = await _uploadImage(_pickedImageFile!);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          imageUrl = uploadedUrl;
        }
      }

      await widget.fs.updateProperty(
        propertyId: widget.property.id,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        imageUrl: imageUrl,
        price: _priceCtrl.text.trim(),
        bedrooms: int.tryParse(_bedroomsCtrl.text.trim()) ?? 0,
        bathrooms: int.tryParse(_bathroomsCtrl.text.trim()) ?? 0,
        area: double.tryParse(_areaCtrl.text.trim()) ?? 0.0,
        description: _descriptionCtrl.text.trim(),
        features: _selectedFeatures.toList(),
        latitude: _latitude,
        longitude: _longitude,
      );

      if (context.mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Propiedad actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                      : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _currentImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image),
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
                          'Editar propiedad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
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
}


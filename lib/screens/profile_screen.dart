import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.fs});

  final FirestoreService fs;

  Future<void> _showAddPropertyDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => _AddPropertyDialog(fs: fs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          _ProfileAvatar(colorScheme: colorScheme),
          const SizedBox(height: 16),
          Text(
            'Julián Gómez',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Santiago, Chile',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
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
              await FirebaseAuth.instance.signOut();
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
                  color: colorScheme.onSurface.withOpacity(0.4),
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
  const _ProfileAvatar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          child: ClipOval(
            child: Image.asset(
              'img/julian.jpg',
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
                  color: colorScheme.primary.withOpacity(0.4),
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
      (Icons.person_outline, 'Perfil'),
      (Icons.bookmark_border, 'Favoritos'),
      (Icons.settings_outlined, 'Configuración'),
      (Icons.credit_card_outlined, 'Métodos de pago'),
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
                      color: colorScheme.primary.withOpacity(0.08),
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
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  onTap: () {},
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
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  bool _isLoadingCoordinates = false;
  double? _latitude;
  double? _longitude;
  String? _coordinateError;

  Future<void> _getCoordinatesFromAddress() async {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      setState(() {
        _coordinateError = 'Ingresa una dirección primero';
        _latitude = null;
        _longitude = null;
      });
      return;
    }

    setState(() {
      _isLoadingCoordinates = true;
      _coordinateError = null;
    });

    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
          _coordinateError = null;
        });
      } else {
        setState(() {
          _coordinateError = 'No se encontró la ubicación';
          _latitude = null;
          _longitude = null;
        });
      }
    } catch (e) {
      setState(() {
        _coordinateError = 'Error al buscar ubicación: ${e.toString()}';
        _latitude = null;
        _longitude = null;
      });
    } finally {
      setState(() {
        _isLoadingCoordinates = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar propiedad'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la propiedad',
                  hintText: 'Ej. Condominio Reina Bernstein',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Dirección',
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
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
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
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ubicación encontrada: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Precio (opcional)',
                  hintText: 'Ej. UF 33.200',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de foto',
                  hintText: 'https://...',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            // Intentar obtener coordenadas si no se han obtenido
            if (_latitude == null || _longitude == null) {
              await _getCoordinatesFromAddress();
            }

            try {
              await widget.fs.addProperty(
                name: _nameCtrl.text.trim(),
                address: _addressCtrl.text.trim(),
                imageUrl: _imageCtrl.text.trim(),
                price: _priceCtrl.text.trim(),
                latitude: _latitude,
                longitude: _longitude,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Propiedad agregada correctamente'),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al guardar: $e'),
                  ),
                );
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

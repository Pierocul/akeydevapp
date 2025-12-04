import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';
import '../utils/slide_up_route.dart';
import 'contacts_screen.dart';
import 'profile_screen.dart';
import 'property_detail_screen.dart';

class PropertyHomeScreen extends StatefulWidget {
  const PropertyHomeScreen({super.key});

  @override
  State<PropertyHomeScreen> createState() => _PropertyHomeScreenState();
}

class _PropertyHomeScreenState extends State<PropertyHomeScreen> {
  int _selectedFilter = 0; // 0: Destacados, 1: Para ti, 2: Nuevos
  int _selectedBottomNav = 0;

  FirestoreService? _fs;

  FirestoreService get fs {
    _fs ??= FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);
    return _fs!;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pinkColor = colorScheme.primary;
    final darkBlueColor = colorScheme.tertiary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _selectedBottomNav == 0
            ? _buildHomeContent(pinkColor, darkBlueColor)
            : _selectedBottomNav == 1
                ? _buildContactsContent()
                : _buildProfileContent(),
      ),
      // Barra de navegación inferior
      bottomNavigationBar: _buildBottomNavigationBar(pinkColor, darkBlueColor),
    );
  }

  Widget _buildHomeContent(Color pinkColor, Color darkBlueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con logo y búsqueda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo con 4 puntos rosados en cuadrícula 2x2
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogoDot(pinkColor),
                      const SizedBox(width: 4),
                      _buildLogoDot(pinkColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogoDot(pinkColor),
                      const SizedBox(width: 4),
                      _buildLogoDot(pinkColor),
                    ],
                  ),
                ],
              ),
              // Icono de búsqueda
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search, color: darkBlueColor, size: 28),
              ),
            ],
          ),
        ),

        // Título y subtítulo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Busca tu Hogar',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3605EB),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Encuentra la mejor casa',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Botones de filtro
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildFilterButton('Destacados', 0, pinkColor),
              const SizedBox(width: 12),
              _buildFilterButton('Para ti', 1, pinkColor),
              const SizedBox(width: 12),
              _buildFilterButton('Nuevos', 2, pinkColor),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Listado de propiedades
        Expanded(
          child: StreamBuilder<List<Property>>(
            stream: fs.watchProperties(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final properties = snapshot.data ?? const <Property>[];

              if (properties.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Aún no hay propiedades. Agrega la primera desde tu perfil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: properties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) => _buildPropertyCard(
                  properties[index],
                  pinkColor,
                  darkBlueColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactsContent() {
    return ContactsScreen(fs: fs);
  }

  Widget _buildProfileContent() {
    return ProfileScreen(fs: fs);
  }

  Widget _buildLogoDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFilterButton(String label, int index, Color pinkColor) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? pinkColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? pinkColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(
    Property property,
    Color pinkColor,
    Color darkBlueColor,
  ) {
    final displayImage = property.imageUrl.isNotEmpty
        ? property.imageUrl
        : Property.defaultImageUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la propiedad
            Stack(
              children: [
                SizedBox(
                  height: 480,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          displayImage,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: pinkColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Log del error para debug
                            if (kDebugMode) {
                              print('Error al cargar imagen: $displayImage');
                              print('Error: $error');
                            }
                            return Container(
                              color: Colors.grey.shade300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error al cargar imagen',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Gradiente rosado/morado sobre la imagen
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                pinkColor.withValues(alpha: 0.3),
                                darkBlueColor.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Información de la propiedad sobre la imagen
                Positioned(
                  top: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.address,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      if (property.price.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          property.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Botones de acción sobre la imagen (en la parte inferior)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              SlideUpRoute(
                                builder: (_) => PropertyDetailScreen(
                                  property: property,
                                  fs: fs,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pinkColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Detalles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: pinkColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.bookmark_border,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(Color pinkColor, Color darkBlueColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedBottomNav,
        onTap: (index) {
          setState(() {
            _selectedBottomNav = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: pinkColor,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedBottomNav == 0 ? pinkColor.withValues(alpha: 0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedBottomNav == 0 ? Icons.home : Icons.home_outlined,
                color: _selectedBottomNav == 0 ? pinkColor : Colors.grey.shade600,
              ),
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedBottomNav == 1 ? Icons.chat_bubble : Icons.chat_bubble_outline,
              color: _selectedBottomNav == 1 ? pinkColor : Colors.grey.shade600,
            ),
            label: 'Contactos',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedBottomNav == 2 ? Icons.person : Icons.person_outline,
              color: _selectedBottomNav == 2 ? pinkColor : Colors.grey.shade600,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}


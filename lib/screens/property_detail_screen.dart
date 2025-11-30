import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/property.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  final Property property;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  GoogleMapController? _mapController;
  bool _mapLoading = true;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    if (widget.property.latitude != null &&
        widget.property.longitude != null &&
        _isValidCoordinate(
            widget.property.latitude!, widget.property.longitude!)) {
      _markers.add(
        Marker(
          markerId: MarkerId(widget.property.id),
          position: LatLng(
            widget.property.latitude!,
            widget.property.longitude!,
          ),
          infoWindow: InfoWindow(
            title: widget.property.name,
            snippet: widget.property.address,
          ),
        ),
      );
    }
    setState(() {
      _mapLoading = false;
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pinkColor = colorScheme.primary;
    final darkBlueColor = colorScheme.tertiary;

    final displayImage = widget.property.imageUrl.isNotEmpty
        ? widget.property.imageUrl
        : Property.defaultImageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenido principal con scroll
          CustomScrollView(
            slivers: [
              // Imagen de la propiedad
              SliverAppBar(
                expandedHeight: 300,
                pinned: false,
                floating: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        displayImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.home,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      // Gradiente oscuro en la parte inferior
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botones de acción en el header
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: pinkColor,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: pinkColor,
                      child: IconButton(
                        icon: const Icon(Icons.bookmark_border,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),

              // Contenido de la propiedad
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre, dirección y precio
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property.name,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: darkBlueColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.property.address,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (widget.property.price.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                widget.property.price,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: darkBlueColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Iconos de baños, habitaciones y metros cuadrados
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoIcon(
                              Icons.bed,
                              '${widget.property.bedrooms}',
                              'Habitaciones',
                              darkBlueColor,
                            ),
                            _buildInfoIcon(
                              Icons.bathtub,
                              '${widget.property.bathrooms}',
                              'Baños',
                              darkBlueColor,
                            ),
                            _buildInfoIcon(
                              Icons.square_foot,
                              '${widget.property.area.toInt()}m²',
                              'Área',
                              darkBlueColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Descripción
                      if (widget.property.description.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Descripción',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.property.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Características
                      if (widget.property.features.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Características',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: pinkColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('Contactar'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...widget.property.features.map((feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: darkBlueColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          feature,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Ubicación
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ubicación',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _mapLoading
                                    ? Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : widget.property.latitude != null &&
                                            widget.property.longitude != null &&
                                            _isValidCoordinate(
                                                widget.property.latitude!,
                                                widget.property.longitude!)
                                        ? GoogleMap(
                                            onMapCreated: (GoogleMapController controller) {
                                              setState(() {
                                                _mapController = controller;
                                              });
                                            },
                                            initialCameraPosition: CameraPosition(
                                              target: LatLng(
                                                widget.property.latitude!,
                                                widget.property.longitude!,
                                              ),
                                              zoom: 15.0,
                                            ),
                                            markers: _markers,
                                            mapType: MapType.normal,
                                            myLocationButtonEnabled: false,
                                            zoomControlsEnabled: false,
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.map,
                                                    size: 48,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Coordenadas no disponibles',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isValidCoordinate(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  Widget _buildInfoIcon(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}


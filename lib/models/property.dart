class Property {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String price;
  final bool isFeatured;
  final int bedrooms;
  final int bathrooms;
  final double area; // metros cuadrados
  final String description;
  final List<String> features; // características como aire acondicionado, estacionamiento, etc.
  final double? latitude;
  final double? longitude;

  static const String defaultImageUrl =
      'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800';

  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.price = '',
    this.isFeatured = false,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.area = 0.0,
    this.description = '',
    this.features = const [],
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'price': price,
      'isFeatured': isFeatured,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'description': description,
      'features': features,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> data) {
    return Property(
      id: id,
      name: (data['name'] as String?) ?? 'Propiedad',
      address: (data['address'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      price: (data['price'] as String?) ?? '',
      isFeatured: (data['isFeatured'] as bool?) ?? false,
      bedrooms: (data['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (data['bathrooms'] as num?)?.toInt() ?? 0,
      area: (data['area'] as num?)?.toDouble() ?? 0.0,
      description: (data['description'] as String?) ?? '',
      features: (data['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}


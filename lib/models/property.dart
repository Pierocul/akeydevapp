class Property {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String price;
  final bool isFeatured;

  static const String defaultImageUrl =
      'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800';

  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.price = '',
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'price': price,
      'isFeatured': isFeatured,
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
    );
  }
}


class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.rating,
    this.isNew = false,
    this.isOnSale = false,
    this.oldPrice,
    this.imageScale = 1,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: _toDouble(map['price']),
      imagePath: map['image_path'] as String? ?? '',
      description: map['description'] as String? ?? '',
      rating: _toDouble(map['rating']),
      isNew: map['is_new'] as bool? ?? false,
      isOnSale: map['is_on_sale'] as bool? ?? false,
      oldPrice: map['old_price'] == null ? null : _toDouble(map['old_price']),
      imageScale: map['image_scale'] == null ? 1 : _toDouble(map['image_scale']),
    );
  }

  final String id;
  final String name;
  final String category;
  final double price;
  final String imagePath;
  final String description;
  final double rating;
  final bool isNew;
  final bool isOnSale;
  final double? oldPrice;
  final double imageScale;

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

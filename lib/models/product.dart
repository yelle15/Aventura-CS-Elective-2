double parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.description = '',
    this.imageUrl,
    this.categoryName = '',
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];
    return Product(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: parseDouble(map['price']),
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      imageUrl: map['image_url'] as String?,
      categoryId: (map['category_id'] as num).toInt(),
      categoryName: category is Map<String, dynamic>
          ? category['name'] as String? ?? ''
          : '',
    );
  }

  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final int categoryId;
  final String categoryName;

  bool get inStock => stock > 0;

  bool get isLowStock => stock > 0 && stock <= 3;

  Product copyWith({int? stock}) {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Product &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.price == price &&
      other.stock == stock &&
      other.imageUrl == imageUrl &&
      other.categoryId == categoryId &&
      other.categoryName == categoryName;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        price,
        stock,
        imageUrl,
        categoryId,
        categoryName,
      );
}

class ProductInput {
  const ProductInput({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.imageUrl,
  });

  final String name;
  final String description;
  final double price;
  final int stock;
  final int categoryId;
  final String? imageUrl;

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
        'image_url': imageUrl,
      };
}

class ProductPage {
  const ProductPage({required this.items, required this.totalCount});

  final List<Product> items;
  final int totalCount;
}

class PriceBounds {
  const PriceBounds(this.min, this.max);

  final double min;
  final double max;
}

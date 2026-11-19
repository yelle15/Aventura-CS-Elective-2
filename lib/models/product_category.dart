class ProductCategory {
  const ProductCategory({required this.id, required this.name});

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
    );
  }

  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ProductCategory && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

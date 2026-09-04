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
}

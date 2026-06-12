class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double pricePerUnit;
  final String unit;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isPopular;
  final bool isNew;
  final int stock;
  final String origin;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.pricePerUnit,
    required this.unit,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.isPopular = false,
    this.isNew = false,
    required this.stock,
    required this.origin,
  });
}

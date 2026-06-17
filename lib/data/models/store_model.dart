class StoreModel {
  final String id;
  final String ownerId;
  final String name;
  final String slug;
  final String description;
  final String logoUrl;
  final String bannerUrl;
  final String address;
  final String city;
  final String province;
  final String phone;
  final String whatsapp;
  final bool isActive;
  final bool isVerified;
  final double rating;
  final int totalSales;
  final int totalProducts;

  const StoreModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.slug,
    this.description = '',
    this.logoUrl = '',
    this.bannerUrl = '',
    this.address = '',
    this.city = '',
    this.province = '',
    this.phone = '',
    this.whatsapp = '',
    this.isActive = false,
    this.isVerified = false,
    this.rating = 0,
    this.totalSales = 0,
    this.totalProducts = 0,
  });

  factory StoreModel.fromMap(Map<String, dynamic> m) => StoreModel(
        id: m['id'] as String,
        ownerId: m['owner_id'] as String,
        name: m['name'] as String,
        slug: m['slug'] as String,
        description: m['description'] as String? ?? '',
        logoUrl: m['logo_url'] as String? ?? '',
        bannerUrl: m['banner_url'] as String? ?? '',
        address: m['address'] as String? ?? '',
        city: m['city'] as String? ?? '',
        province: m['province'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        whatsapp: m['whatsapp'] as String? ?? '',
        isActive: m['is_active'] as bool? ?? false,
        isVerified: m['is_verified'] as bool? ?? false,
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        totalSales: m['total_sales'] as int? ?? 0,
        totalProducts: m['total_products'] as int? ?? 0,
      );
}

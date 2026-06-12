import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart';

class ProductRepository {
  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'all',
      name: 'Semua',
      emoji: '🌽',
      description: 'Semua produk jagung',
    ),
    CategoryModel(
      id: 'segar',
      name: 'Segar',
      emoji: '🌱',
      description: 'Jagung segar pilihan',
    ),
    CategoryModel(
      id: 'manis',
      name: 'Manis',
      emoji: '🍯',
      description: 'Jagung manis premium',
    ),
    CategoryModel(
      id: 'olahan',
      name: 'Olahan',
      emoji: '🏭',
      description: 'Produk olahan jagung',
    ),
    CategoryModel(
      id: 'benih',
      name: 'Benih',
      emoji: '🌾',
      description: 'Benih jagung unggul',
    ),
  ];

  static const List<BannerModel> banners = [
    BannerModel(
      id: '1',
      title: 'Jagung Manis\nSuper Premium',
      subtitle: 'Langsung dari kebun petani\nlokal Kalimantan',
      imageUrl:
          'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400',
      backgroundColor: 'F5C518',
      actionLabel: 'Belanja Sekarang',
    ),
    BannerModel(
      id: '2',
      title: 'Gratis Ongkir\nse-Kalimantan',
      subtitle: 'Minimum pembelian\n50.000 saja!',
      imageUrl:
          'https://images.unsplash.com/photo-1559181567-c3190ca9d5db?w=400',
      backgroundColor: '2D6A4F',
      actionLabel: 'Klaim Promo',
    ),
    BannerModel(
      id: '3',
      title: 'Benih Unggul\nHasil Terbaik',
      subtitle: 'Produktivitas tinggi\ncocok untuk lahan lokal',
      imageUrl:
          'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?w=400',
      backgroundColor: '52B788',
      actionLabel: 'Lihat Koleksi',
    ),
  ];

  static const List<ProductModel> products = [
    ProductModel(
      id: '1',
      name: 'Jagung Manis Super',
      description:
          'Jagung manis pilihan dari petani lokal Kalimantan Timur. Dipanen segar setiap hari dengan kadar gula tinggi dan tekstur renyah.',
      price: 25000,
      pricePerUnit: 5000,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=300',
      category: 'manis',
      rating: 4.9,
      reviewCount: 312,
      isPopular: true,
      isNew: false,
      stock: 150,
      origin: 'Kutai Kartanegara, Kaltim',
    ),
    ProductModel(
      id: '2',
      name: 'Jagung Pipil Kering',
      description:
          'Jagung pipil kering berkualitas tinggi, siap olah untuk berbagai kebutuhan industri maupun rumah tangga.',
      price: 18000,
      pricePerUnit: 3600,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1489421506538-13b72c0e6c77?w=300',
      category: 'olahan',
      rating: 4.7,
      reviewCount: 187,
      isPopular: true,
      isNew: false,
      stock: 500,
      origin: 'Berau, Kaltim',
    ),
    ProductModel(
      id: '3',
      name: 'Jagung Segar Lokal',
      description:
          'Jagung segar lokal yang dipetik langsung dari kebun. Cocok untuk direbus, dibakar, atau diolah menjadi berbagai hidangan.',
      price: 15000,
      pricePerUnit: 3000,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1601593346740-925612772716?w=300',
      category: 'segar',
      rating: 4.6,
      reviewCount: 98,
      isPopular: false,
      isNew: true,
      stock: 200,
      origin: 'Penajam, Kaltim',
    ),
    ProductModel(
      id: '4',
      name: 'Benih Jagung NK-212',
      description:
          'Benih jagung hibrida unggul dengan produktivitas 10-12 ton/ha. Tahan penyakit dan cocok untuk iklim Kalimantan.',
      price: 85000,
      pricePerUnit: 85000,
      unit: 'bungkus',
      imageUrl:
          'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?w=300',
      category: 'benih',
      rating: 4.8,
      reviewCount: 256,
      isPopular: true,
      isNew: false,
      stock: 75,
      origin: 'Samarinda, Kaltim',
    ),
    ProductModel(
      id: '5',
      name: 'Jagung Pulut Ketan',
      description:
          'Jagung pulut atau ketan dengan tekstur lengket khas, sangat populer di Kalimantan. Sempurna untuk olahan kue tradisional.',
      price: 30000,
      pricePerUnit: 6000,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1559181567-c3190ca9d5db?w=300',
      category: 'manis',
      rating: 4.5,
      reviewCount: 143,
      isPopular: false,
      isNew: true,
      stock: 80,
      origin: 'Balikpapan, Kaltim',
    ),
    ProductModel(
      id: '6',
      name: 'Tepung Jagung Premium',
      description:
          'Tepung jagung halus hasil olahan modern, bebas gluten, cocok untuk berbagai kebutuhan memasak dan industri makanan.',
      price: 22000,
      pricePerUnit: 22000,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300',
      category: 'olahan',
      rating: 4.4,
      reviewCount: 67,
      isPopular: false,
      isNew: true,
      stock: 300,
      origin: 'Samarinda, Kaltim',
    ),
  ];

  List<ProductModel> getProducts({String? category}) {
    if (category == null || category == 'all') return products;
    return products.where((p) => p.category == category).toList();
  }

  List<ProductModel> getPopularProducts() =>
      products.where((p) => p.isPopular).toList();

  List<ProductModel> getNewProducts() =>
      products.where((p) => p.isNew).toList();

  List<ProductModel> searchProducts(String query) {
    final q = query.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }
}

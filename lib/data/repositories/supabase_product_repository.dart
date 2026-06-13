import 'dart:io';
import 'package:corn_market/core/config/supabase_config.dart';
import 'package:corn_market/data/models/banner_model.dart';
import 'package:corn_market/data/models/category_model.dart';
import 'package:corn_market/data/models/product_model.dart';
import 'package:corn_market/data/repositories/interfaces/repository_interfaces.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProductRepository implements IProductRepository {
  final _db = Supabase.instance.client;

  // ── Products ──────────────────────────────────────────────

  @override
  Future<List<ProductModel>> getProducts({
    String? categorySlug,
    String? query,
  }) async {
    var q = _db.from('products').select().eq('is_active', true);

    if (categorySlug != null && categorySlug != 'all') {
      q = q.eq('category_slug', categorySlug);
    }

    if (query != null && query.isNotEmpty) {
      q = q.ilike('name', '%$query%');
    }

    final data = await q.order('created_at', ascending: false);
    return (data as List).map((e) => _productFromMap(e)).toList();
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    final data = await _db
        .from('products')
        .select()
        .eq('is_active', true)
        .eq('is_popular', true)
        .order('rating', ascending: false)
        .limit(10);
    return (data as List).map((e) => _productFromMap(e)).toList();
  }

  @override
  Future<List<ProductModel>> getNewProducts() async {
    final data = await _db
        .from('products')
        .select()
        .eq('is_active', true)
        .eq('is_new', true)
        .order('created_at', ascending: false)
        .limit(6);
    return (data as List).map((e) => _productFromMap(e)).toList();
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final data = await _db.from('products').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return _productFromMap(data);
  }

  // ── Realtime products stream ──────────────────────────────

  @override
  Stream<List<ProductModel>> watchProducts({String? categorySlug}) {
    return _db
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) {
          var list = rows.map((e) => _productFromMap(e)).toList();
          if (categorySlug != null && categorySlug != 'all') {
            list = list.where((p) => p.category == categorySlug).toList();
          }
          return list;
        });
  }

  // ── Categories ────────────────────────────────────────────

  @override
  Future<List<CategoryModel>> getCategories() async {
    final data = await _db.from('categories').select().order('sort_order');
    return (data as List).map((e) => _categoryFromMap(e)).toList();
  }

  // ── Banners ───────────────────────────────────────────────

  @override
  Future<List<BannerModel>> getBanners() async {
    final data = await _db
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (data as List).map((e) => _bannerFromMap(e)).toList();
  }

  // ── Storage: upload product image ─────────────────────────

  @override
  Future<String> uploadProductImage(String filePath) async {
    final file = File(filePath);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final storagePath = 'uploads/$fileName';

    await _db.storage
        .from(SupabaseConfig.productsBucket)
        .upload(storagePath, file);

    final publicUrl = _db.storage
        .from(SupabaseConfig.productsBucket)
        .getPublicUrl(storagePath);

    return publicUrl;
  }

  // ── Mappers ───────────────────────────────────────────────

  ProductModel _productFromMap(Map<String, dynamic> m) => ProductModel(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String? ?? '',
        price: (m['price'] as num).toDouble(),
        pricePerUnit: (m['price_per_unit'] as num).toDouble(),
        unit: m['unit'] as String? ?? 'kg',
        imageUrl: m['image_url'] as String? ?? '',
        category: m['category_slug'] as String? ?? '',
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: m['review_count'] as int? ?? 0,
        isPopular: m['is_popular'] as bool? ?? false,
        isNew: m['is_new'] as bool? ?? false,
        stock: m['stock'] as int? ?? 0,
        origin: m['origin'] as String? ?? '',
      );

  CategoryModel _categoryFromMap(Map<String, dynamic> m) => CategoryModel(
        id: m['slug'] as String,
        name: m['name'] as String,
        emoji: m['emoji'] as String? ?? '🌽',
        description: m['description'] as String? ?? '',
      );

  BannerModel _bannerFromMap(Map<String, dynamic> m) => BannerModel(
        id: m['id'] as String,
        title: m['title'] as String,
        subtitle: m['subtitle'] as String? ?? '',
        imageUrl: m['image_url'] as String? ?? '',
        backgroundColor: m['background_color'] as String? ?? 'F5C518',
        actionLabel: m['action_label'] as String?,
      );
}

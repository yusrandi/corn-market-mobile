import 'package:corn_market/data/models/review_model.dart';
import 'package:corn_market/data/repositories/interfaces/repository_interfaces.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseReviewRepository implements IReviewRepository {
  final _db = Supabase.instance.client;

  @override
  Future<List<ReviewModel>> getReviews(String productId) async {
    final data = await _db
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false)
        .limit(20);

    return (data as List).map((e) => _fromMap(e)).toList();
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    await _db.from('reviews').insert({
      'product_id': review.id.isEmpty ? null : null, // set from caller
      'user_id': userId,
      'user_name': review.userName,
      'user_avatar': review.userAvatar,
      'rating': review.rating,
      'comment': review.comment,
      'images': review.images,
      'is_verified': review.isVerified,
    });
  }

  ReviewModel _fromMap(Map<String, dynamic> m) => ReviewModel(
        id: m['id'] as String,
        userName: m['user_name'] as String? ?? 'Pengguna',
        userAvatar: m['user_avatar'] as String? ?? 'https://i.pravatar.cc/100',
        rating: (m['rating'] as num).toDouble(),
        comment: m['comment'] as String? ?? '',
        createdAt: DateTime.parse(m['created_at'] as String),
        images: List<String>.from(m['images'] as List? ?? []),
        isVerified: m['is_verified'] as bool? ?? false,
      );
}

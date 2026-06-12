class ReviewModel {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;
  final bool isVerified;

  const ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
    this.isVerified = false,
  });
}

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String backgroundColor;
  final String? actionLabel;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    this.actionLabel,
  });
}

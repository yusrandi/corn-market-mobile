class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String address;
  final int totalOrders;
  final double totalSpent;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.address,
    required this.totalOrders,
    required this.totalSpent,
  });
}

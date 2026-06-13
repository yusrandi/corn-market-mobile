import 'dart:io';
import 'package:corn_market/core/config/supabase_config.dart';
import 'package:corn_market/data/models/user_model.dart';
import 'package:corn_market/data/repositories/interfaces/repository_interfaces.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final _client = Supabase.instance.client;

  // ── Login ─────────────────────────────────────────────────

  @override
  Future<UserModel?> login(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    if (res.user == null) return null;
    return _fetchProfile(res.user!.id);
  }

  // ── Register ──────────────────────────────────────────────

  @override
  Future<UserModel?> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name, 'phone': phone},
    );
    if (res.user == null) return null;

    // Update profile (trigger handles insert, we update extra fields)
    await _client.from('profiles').update({
      'name': name,
      'phone': phone,
    }).eq('id', res.user!.id);

    return _fetchProfile(res.user!.id);
  }

  // ── Logout ────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // ── Get current user ──────────────────────────────────────

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  // ── Update profile ────────────────────────────────────────

  @override
  Future<UserModel?> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarPath,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    String? avatarUrl;

    // Upload avatar if provided
    if (avatarPath != null) {
      final file = File(avatarPath);
      final ext = avatarPath.split('.').last;
      final storagePath = '$userId/avatar.$ext';

      await _client.storage.from(SupabaseConfig.avatarsBucket).upload(
          storagePath, file,
          fileOptions: const FileOptions(upsert: true));

      avatarUrl = _client.storage
          .from(SupabaseConfig.avatarsBucket)
          .getPublicUrl(storagePath);
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }

    return _fetchProfile(userId);
  }

  // ── Auth state stream (realtime) ──────────────────────────

  @override
  Stream<UserModel?> watchAuthState() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      return _fetchProfile(user.id);
    });
  }

  // ── Helper: fetch profile from DB ─────────────────────────

  Future<UserModel?> _fetchProfile(String userId) async {
    final data =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return _profileFromMap(data, userId);
  }

  UserModel _profileFromMap(Map<String, dynamic> m, String userId) => UserModel(
        id: userId,
        name: m['name'] as String? ?? '',
        email: _client.auth.currentUser?.email ?? '',
        phone: m['phone'] as String? ?? '',
        avatarUrl: m['avatar_url'] as String?,
        address: m['address'] as String? ?? '',
        totalOrders: m['total_orders'] as int? ?? 0,
        totalSpent: (m['total_spent'] as num?)?.toDouble() ?? 0,
      );
}

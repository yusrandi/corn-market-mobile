/// Konfigurasi Supabase
///
/// Cara mendapatkan nilai ini:
/// 1. Buka https://supabase.com/dashboard
/// 2. Pilih project kamu
/// 3. Pergi ke Settings → API
/// 4. Copy "Project URL" dan "anon public" key
/// 5. Paste di bawah ini
class SupabaseConfig {
  SupabaseConfig._();

  // ⚠️  GANTI dengan URL dan key project Supabase kamu!
  static const String url = 'https://artbwjkfisevpclqlqjl.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFydGJ3amtmaXNldnBjbHFscWpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyOTczNzUsImV4cCI6MjA5Njg3MzM3NX0.QFHV56iDBspuaDg2k5IZMhjzdhJirQnZ1ROHR5BXVjQ';

  // Storage bucket names (buat dulu di Supabase Dashboard → Storage)
  static const String productsBucket = 'products';
  static const String avatarsBucket = 'avatars';

  // Storage base URL (otomatis dari url di atas)
  static String get storageUrl => '$url/storage/v1/object/public';
  static String get productsStorageUrl => '$storageUrl/$productsBucket';
  static String get avatarsStorageUrl => '$storageUrl/$avatarsBucket';
}

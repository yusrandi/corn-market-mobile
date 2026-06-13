# 🌽 CornMarket — Supabase Setup Guide

Panduan lengkap menghubungkan CornMarket ke Supabase backend.

---

## 1. Buat Project Supabase

1. Buka [supabase.com](https://supabase.com) → **New Project**
2. Isi nama project: `corn-market`
3. Pilih region terdekat: **Southeast Asia (Singapore)**
4. Buat database password yang kuat → **Create Project**
5. Tunggu ~2 menit sampai project siap

---

## 2. Jalankan SQL Schema

1. Di Supabase Dashboard → **SQL Editor** → **New Query**
2. Copy isi file `supabase_schema.sql`
3. Paste ke editor → klik **Run**
4. Pastikan tidak ada error merah

---

## 3. Buat Storage Buckets

1. Dashboard → **Storage** → **New Bucket**
2. Buat bucket **`products`**:
   - Name: `products`
   - Public bucket: ✅ ON
   - → **Create**
3. Buat bucket **`avatars`**:
   - Name: `avatars`
   - Public bucket: ✅ ON
   - → **Create**

### Storage Policies

Untuk bucket `products`, tambahkan policy:
- **Select** (read): `true` (semua bisa baca)
- **Insert** (upload): `auth.role() = 'authenticated'`

Untuk bucket `avatars`:
- **Select**: `true`
- **Insert**: `auth.uid()::text = (storage.foldername(name))[1]`

---

## 4. Copy API Keys

1. Dashboard → **Settings** → **API**
2. Copy nilai berikut:

```
Project URL  : https://xxxxxxxxxxxx.supabase.co
anon public  : eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

3. Paste ke `lib/core/config/supabase_config.dart`:

```dart
static const String url     = 'https://xxxxxxxxxxxx.supabase.co';
static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## 5. Konfigurasi Auth

1. Dashboard → **Authentication** → **Providers**
2. Pastikan **Email** provider sudah enabled
3. Opsional: matikan "Confirm email" untuk development
   - Authentication → **Settings** → Email confirmations → OFF

---

## 6. Jalankan Aplikasi

```bash
cd corn_market
flutter pub get
flutter run
```

---

## 7. Fitur yang Sudah Terintegrasi

| Fitur | Status | Keterangan |
|---|---|---|
| **Auth: Login** | ✅ Real | Email + password via Supabase Auth |
| **Auth: Register** | ✅ Real | Auto-create profile via trigger |
| **Auth: Session** | ✅ Real | Persist login via Supabase session |
| **Produk** | ✅ Real | Fetch dari tabel `products` |
| **Kategori** | ✅ Real | Fetch dari tabel `categories` |
| **Banner** | ✅ Real | Fetch dari tabel `banners` |
| **Ulasan** | ✅ Real | Fetch dari tabel `reviews` |
| **Buat Pesanan** | ✅ Real | Insert ke `orders` + `order_items` |
| **Riwayat Pesanan** | ✅ Real | Fetch by user_id |
| **Upload Avatar** | ✅ Real | Supabase Storage bucket `avatars` |
| **Realtime Stok** | ✅ Real | WebSocket via `supabase_flutter` stream |
| **Realtime Pesanan** | ✅ Real | Stream single order status |
| **Dark Mode** | ✅ Lokal | SharedPreferences |
| **Onboarding flag** | ✅ Lokal | SharedPreferences |

---

## 8. Struktur Arsitektur

```
Abstract Interface (IProductRepository)
         ↕
Supabase Implementation (SupabaseProductRepository)
         ↕
GetX Controller (HomeController)
         ↕
Flutter Widget (HomePage)
```

Untuk mengganti backend (misal ke Firebase), cukup buat implementasi baru
dari interface yang sama — tanpa ubah controller atau UI sama sekali.

---

## 9. Environment Variables (Production)

Untuk production, jangan hardcode keys. Gunakan `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
```

Lalu di `supabase_config.dart`:

```dart
static const String url     = String.fromEnvironment('SUPABASE_URL');
static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

---

## 10. Troubleshooting

| Error | Solusi |
|---|---|
| `Invalid API key` | Cek anonKey di supabase_config.dart |
| `row-level security` error | Pastikan RLS policies sudah dibuat |
| `relation "profiles" does not exist` | Jalankan ulang supabase_schema.sql |
| Upload gagal | Pastikan bucket sudah dibuat dan policy insert aktif |
| Realtime tidak update | Cek koneksi internet, pastikan `realtimeClientOptions` diset |

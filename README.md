# 🌽 CornMarket - E-Commerce Penjualan Jagung

Aplikasi Flutter e-commerce untuk penjualan jagung dengan desain minimalis modern dan tema jagung khas Kalimantan.

---

## 🏗️ Arsitektur

Project ini menggunakan **Clean Architecture** dengan struktur folder sebagai berikut:

```
lib/
├── core/                     # Layer inti aplikasi
│   ├── constants/            # Konstanta global (spacing, radius, dll)
│   ├── theme/                # Tema, warna, dan typography
│   └── utils/                # Utility & helper functions
│
├── data/                     # Layer data
│   ├── models/               # Data models (ProductModel, BannerModel, dll)
│   └── repositories/         # Repository & sumber data
│
└── presentation/             # Layer UI
    ├── controllers/          # GetX controllers (business logic)
    ├── pages/                # Halaman/screen utama
    └── widgets/              # Widget reusable
```

---

## 🚀 Teknologi yang Digunakan

| Teknologi       | Kegunaan                    |
|-----------------|-----------------------------|
| **Flutter**     | Framework UI                |
| **GetX**        | State management & routing  |
| **Google Fonts**| Custom font (Poppins)       |
| **Intl**        | Format mata uang Rupiah     |

---

## 🎨 Design System

### Warna
| Token             | Hex       | Fungsi                  |
|-------------------|-----------|-------------------------|
| `primary`         | `#F5C518` | Kuning jagung (CTA)     |
| `secondary`       | `#2D6A4F` | Hijau daun (harga)      |
| `background`      | `#FFF8E7` | Background utama        |
| `textPrimary`     | `#1A1A2E` | Teks utama              |

### Typography
- **Font:** Poppins (Google Fonts)
- **Display:** 32px / Bold
- **Headline:** 18-24px / SemiBold
- **Body:** 13-14px / Regular
- **Label:** 12px / Medium

---

## 📱 Fitur Homepage

- ✅ **App Bar** - Logo CornMarket + lokasi + search + cart dengan badge
- ✅ **Search Bar** - Animasi muncul/hilang dengan filter real-time
- ✅ **Banner Slider** - Promo dengan page indicator animasi
- ✅ **Stats Banner** - Statistik platform (petani, jenis, rating, pelanggan)
- ✅ **Produk Populer** - Horizontal scroll dengan ProductCard
- ✅ **Category Tabs** - Filter kategori dengan animasi pill
- ✅ **Product Grid** - 2 kolom responsive dengan lazy loading
- ✅ **Bottom Navigation** - 5 tab dengan animasi aktif
- ✅ **Empty State** - Tampilan saat produk tidak ditemukan

---

## ⚙️ Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run

# Build APK
flutter build apk --release
```

---

## 📝 Catatan

- Gambar menggunakan URL Unsplash (butuh koneksi internet)
- Data produk menggunakan dummy data lokal
- Font Poppins di-load via Google Fonts CDN
- Untuk produksi, tambahkan API service layer di `data/repositories/`

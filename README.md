# 🌽 CornMarket — E-Commerce Penjualan Jagung

Aplikasi Flutter e-commerce lengkap untuk penjualan jagung dengan desain minimalis modern, tema jagung Kalimantan, dark mode, dan clean architecture.

---

## 📁 Struktur Clean Architecture

```
lib/
├── core/
│   ├── constants/      → AppConstants, AppRoutes
│   ├── theme/          → AppColors, AppTextStyles, AppTheme (light & dark)
│   └── utils/          → CurrencyFormatter
│
├── data/
│   ├── models/         → ProductModel, CartItemModel, OrderModel,
│   │                     ReviewModel, UserModel, BannerModel, CategoryModel
│   └── repositories/   → ProductRepository, ReviewRepository, OrderRepository
│
└── presentation/
    ├── controllers/    → HomeController, AuthController, CartController,
    │                     FavoritesController, ThemeController, MainController
    ├── pages/          → 11 halaman lengkap
    └── widgets/        → Widget reusable + common/
```

---

## 📱 Halaman Lengkap

| Halaman            | Fitur Utama                                          |
|--------------------|------------------------------------------------------|
| **Login**          | Validasi form, demo login, navigasi ke Register      |
| **Register**       | Form lengkap, toggle password                        |
| **Home**           | Banner slider, produk populer, kategori, search      |
| **Kategori**       | Grid kategori, sort (harga/rating), filter range harga |
| **Detail Produk**  | Hero image, qty selector, rating summary, ulasan     |
| **Keranjang**      | Qty +/−, subtotal, gratis ongkir threshold           |
| **Checkout**       | Alamat, pilih pembayaran, ringkasan biaya            |
| **Order Success**  | Animasi sukses, info pesanan                         |
| **Riwayat Pesanan**| Daftar pesanan + status badge                        |
| **Detail Pesanan** | Tracking timeline, detail produk, ringkasan bayar    |
| **Profil**         | Stats, dark mode toggle, menu pengaturan, logout     |

---

## 🎨 Design System

| Token           | Light              | Dark               |
|-----------------|--------------------|--------------------|
| Background      | `#FFF8E7` krem     | `#0F1117` gelap    |
| Surface         | `#FFFFFF` putih    | `#1C1F26` abu tua  |
| Primary         | `#F5C518` kuning jagung | sama          |
| Secondary       | `#2D6A4F` hijau daun | `#52B788` terang |
| Font            | Poppins via Google Fonts | sama         |

---

## 🚀 Cara Menjalankan

```bash
cd corn_market
flutter pub get
flutter run
```

> Login Demo: gunakan tombol **"Login Demo"** di halaman login, atau isi email & password apa saja (min 6 karakter).

---

## 🛠 Stack

- **Flutter** 3.x + **Dart** 3.x
- **GetX** — state management, routing, dependency injection
- **Google Fonts** — Poppins
- **Intl** — format Rupiah

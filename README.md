# Dimsumia Manager — Untuk Nabila 💕

Aplikasi manajemen usaha dimsum lokal, pink kawaii, khusus untuk Nabila Salsabila Wardana.

## Fitur Lengkap

| Modul | Status | Keterangan |
|-------|--------|------------|
| Splash | ✅ | Personal untuk Nabila 💕 |
| Dashboard | ✅ | Ringkasan harian, laba, stok, tren 7 hari, best seller |
| Penjualan | ✅ | CRUD transaksi, input cepat, pagination, PDF |
| Produksi | ✅ | CRUD produksi, stock deduction otomatis, cari/filter, pagination |
| Stok | ✅ | Manajemen bahan, indikator aman/menipis/habis, pembelian, penyesuaian, cari/filter, pagination |
| HPP | ✅ | Kalkulasi resep → HPP + margin, form produk baru (nama, emoji, kategori, harga, satuan) |
| Pelanggan | ✅ | CRUD + ranking belanja + cari |
| Hutang | ✅ | CRUD + filter status + PDF |
| Laporan | ✅ | Grafik penjualan/laba/best seller, PDF export |
| Pengaturan | ✅ | Backup/restore DB, info aplikasi |

## Changelog — Semua Perubahan

### Bug Fix
| Fix | File |
|-----|------|
| `use_build_context_synchronously` (6 → 0) | produksi, stok screen |
| `DropdownButtonFormField` parameter `initialValue` → `value` | `transaction_form_screen.dart` |
| Hapus duplikat ` production_form_screen.dart` di stok/ | dihapus, import diarahkan ke produksi/ |
| `prefer_const_constructors` di PDF service | `pdf_export_service.dart` |
| `@visibleForTesting` import (`meta` → `foundation`) | `database_helper.dart`, provider files |
| Hapus unused imports | `hpp_provider_test.dart`, `pdf_export_service.dart` |
| Duplikasi method `setSearchQuery` + `filteredItems` di `bahan_provider.dart` | Dihapus |

### Fitur Baru
| Fitur | Detail |
|-------|--------|
| **Pesan Cinta** | `PesanCinta` widget — 8 kutipan romantis untuk Nabila, berganti setiap hari |
| **Personal branding** | Splash screen footer: "Untuk Nabila Salsabila Wardana 💕"; FeatureHeader + Dashboard: pesan cinta harian |
| **Search & Filter** | Cari di Produksi (produk/catatan), Stok (nama/kategori), Pelanggan (nama/wa) — filter chips |
| **Pagination** | Penjualan: `_page`, `_hasMore`, `loadMore()`, ScrollController 80% threshold. Stok & Produksi: DB layer + provider siap |
| **PDF Export** | `generateStokPdf()` + `generateHutangPdf()` — tema pink, font Helvetica, tabel striped, share via share sheet |
| **Crash logging lokal** | `CrashService` — log error ke file `crash_log.txt` di dokumen aplikasi |
| **CI/CD** | `.github/workflows/ci.yml` — analyze + test + build APK debug otomatis |
| **ProductFormScreen** | Form create & edit produk (nama, emoji, kategori, harga jual, satuan) — langsung dari HPP screen |
| **HPP Atur Resep** | Tombol "Atur Resep" di komposisi bahan — edit resep langsung |
| **HPP Ubah Harga** | Tombol "Ubah Harga" di kartu produk — edit harga jual |

### Penghapusan
| Item | Alasan |
|------|--------|
| Dark mode toggle (`_ThemeCard`) | Tema gelap jelek di tema pink — toggle dihapus dari UI, provider tetap ada (YAGNI) |

### Testing
| Item | Status |
|------|--------|
| Provider unit test (HPP, Bahan, Production) | ✅ 12 test |
| `flutter analyze` | ✅ **No issues found!** (0 error, 0 warning) |
| Cakupan | FilteredItems logic, previewHpp calculation |

## Tech Stack

| Lapisan | Teknologi |
|---------|-----------|
| UI | Flutter (Material 3, custom kawaii theme) |
| State | Provider (ChangeNotifier, ChangeNotifierProxyProvider) |
| DB | SQLite (sqflite) — lokal, tanpa server |
| Chart | fl_chart |
| PDF | pdf + printing (Helvetica, tanpa font file eksternal) |
| Crash Log | Lokal — file `crash_log.txt` |
| CI/CD | GitHub Actions (.github/workflows/ci.yml) |

## Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build APK (kirim ke WhatsApp Nabila)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Analyze code
flutter analyze

# Test
flutter test

# Generate launcher icons
dart run flutter_launcher_icons

# Clean
flutter clean
flutter pub get
```

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_dimens.dart
│   ├── services/
│   │   ├── backup_service.dart
│   │   └── crash_service.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── format.dart
│   │   └── routes.dart
│   └── widgets/
│       ├── common/ (10 reusable widgets)
│       │   ├── app_card.dart
│       │   ├── empty_state.dart
│       │   ├── feature_header.dart
│       │   ├── icon_bubble.dart
│       │   ├── kawaii_badge.dart
│       │   ├── pesan_cinta.dart
│       │   ├── primary_button.dart
│       │   ├── section_title.dart
│       │   ├── skeleton_loading.dart
│       │   └── stat_card.dart
│       └── ornament/
├── data/
│   ├── database/
│   │   └── database_helper.dart
│   ├── models/
│   │   ├── transaction.dart
│   │   ├── product.dart
│   │   ├── bahan.dart
│   │   ├── production.dart
│   │   ├── customer.dart
│   │   ├── debt.dart
│   │   ├── resep_item.dart
│   │   └── stock_transaction.dart
│   └── dummy/
│       └── dummy_data.dart
├── providers/
│   ├── transaction_provider.dart   (pagination ✅)
│   ├── product_provider.dart
│   ├── bahan_provider.dart         (pagination ✅)
│   ├── hpp_provider.dart
│   ├── production_provider.dart    (pagination ✅)
│   ├── customer_provider.dart
│   ├── debt_provider.dart
│   ├── report_provider.dart
│   ├── stock_provider.dart
│   ├── theme_provider.dart
│   └── dashboard_provider.dart
└── features/
    ├── splash/
    ├── main/
    ├── dashboard/
    ├── penjualan/
    ├── produksi/
    ├── stok/
    ├── pelanggan/
    ├── hutang/
    ├── hpp/
    │   ├── hpp_screen.dart
    │   └── product_form_screen.dart   # Baru!
    ├── laporan/
    │   └── pdf_export_service.dart
    └── pengaturan/
```

## Theme

- Palet pink: `#FFD1DC` (soft), `#F472A8` (hot), `#E8557E` (deep), `#FFF8F0` (cream)
- Ornamen kawaii: sparkle, bunga, pita (CustomPainter)
- Font: Baloo 2 (display), Quicksand (body) — via Google Fonts
- Corner radius besar, soft shadow
- **Dark mode dihapus** — tema gelap tidak cocok dengan identitas pink kawaii

## Database

SQLite lokal — semua data tersimpan di device. Tidak ada backend.

```
# Android debug: data/data/com.dimsumia.manager/databases/
# Gunakan Android Studio → Device Explorer
```

## Catatan Penggunaan

- **Transaksi**: 1 transaksi = 1 line item. Qty > 1 = 1 transaksi dengan jumlah > 1. HPP di-snapshot saat transaksi dibuat.
- **HPP**: Dihitung dari `resep_items` (Σ hargaBeli × qtyUsed). Buka menu HPP → tap produk → atur resep untuk melihat/mengedit.
- **Pagination**: Penjualan sudah infinite scroll (ScrollController 80% threshold, 20 item/page). Stok & Produksi sudah siap di DB + provider, screen layer bisa ditambahkan nanti.
- **PDF Export**: Share otomatis via share sheet. Tidak perlu font file eksternal (pakai Helvetica built-in).
- **Crash Log**: Tersimpan di dokumen aplikasi. Bisa diakses via menu Pengaturan → bagikan log.
- **Aplikasi ini untuk Nabila Salsabila Wardana 💕** — pesan cinta berganti setiap hari di setiap halaman.

import '../models/bahan.dart';
import '../models/product.dart';
import '../models/resep_item.dart';
import '../models/transaction.dart';

/// 🎀 Data dummy untuk Dimsumia Manager.
/// Master Bahan (harga beli + stok), Produk, Resep per produk, dan Transaksi.
///
/// HPP per produk = Σ (hargaBeli × qtyUsed) sesuai resep.
/// Dibawah ini dummy dirancang supaya resep menghasilkan HPP yang wajar
/// terhadap harga jual tiap produk.
class DummyData {
  DummyData._();

  static DateTime _today([int hour = 10, int minute = 0]) {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static DateTime _daysAgo(int days, [int hour = 11]) => _today(hour).subtract(Duration(days: days));

  // ---------------- BAHAN ----------------
  /// Master bahan dengan harga beli per unit & stok.
  static final List<Bahan> bahans = [
    Bahan(id: 1, name: 'Kulit Dimsum', unit: 'pcs', buyPrice: 300, stock: 320, minStock: 100, emoji: '🥡', category: 'Kulit'),
    Bahan(id: 2, name: 'Daging Ayam Giling', unit: 'gram', buyPrice: 40, stock: 850, minStock: 500, emoji: '🍗', category: 'Isi'),
    Bahan(id: 3, name: 'Udang Segar', unit: 'gram', buyPrice: 90, stock: 180, minStock: 250, emoji: '🦐', category: 'Isi'),
    Bahan(id: 4, name: 'Tepung Tapioka', unit: 'gram', buyPrice: 18, stock: 1200, minStock: 400, emoji: '🌾', category: 'Tepung'),
    Bahan(id: 5, name: 'Mayones', unit: 'ml', buyPrice: 35, stock: 0, minStock: 200, emoji: '🥛', category: 'Topping'),
    Bahan(id: 6, name: 'Saus Rujak', unit: 'ml', buyPrice: 25, stock: 250, minStock: 200, emoji: '🥫', category: 'Topping'),
    Bahan(id: 7, name: 'Kepiting', unit: 'gram', buyPrice: 150, stock: 90, minStock: 150, emoji: '🦀', category: 'Isi'),
    Bahan(id: 8, name: 'Jamur Tiram', unit: 'gram', buyPrice: 30, stock: 400, minStock: 200, emoji: '🍄', category: 'Isi'),
    Bahan(id: 9, name: 'Daun Bawang', unit: 'gram', buyPrice: 20, stock: 150, minStock: 80, emoji: '🧅', category: 'Bumbu'),
    Bahan(id: 10, name: 'Bawang Putih', unit: 'gram', buyPrice: 30, stock: 200, minStock: 100, emoji: '🧄', category: 'Bumbu'),
  ];

  // ---------------- PRODUK ----------------
  static final List<Product> products = [
    Product(id: 1, name: 'Dimsum Ayam', emoji: '🥟', category: 'Steam', sellingPrice: 15000, unit: 'pcs', description: 'Dimsum ayam klasik dengan saus mayo.'),
    Product(id: 2, name: 'Dimsum Udang', emoji: '🍤', category: 'Steam', sellingPrice: 18000, unit: 'pcs', description: 'Dimsum udang segar, jumbo.'),
    Product(id: 3, name: 'Cireng Rujak', emoji: '🫓', category: 'Goreng', sellingPrice: 10000, unit: 'porsi', description: 'Cireng krispi dengan saus rujak pedas.'),
    Product(id: 4, name: 'Batagor', emoji: '🍥', category: 'Goreng', sellingPrice: 12000, unit: 'porsi', description: 'Batagor khas Bandung, gurih.'),
    Product(id: 5, name: 'Dimsum Crab', emoji: '🦀', category: 'Steam', sellingPrice: 17000, unit: 'pcs', description: 'Dimsum isi kepiting premium.'),
    Product(id: 6, name: 'Dimsum Jamur', emoji: '🍄', category: 'Steam', sellingPrice: 13000, unit: 'pcs', description: 'Dimsum jamur tiram, opsi vegan.'),
  ];

  // ---------------- RESEP ----------------
  /// Resep: (productId, bahanId, qtyUsed).
  /// Disusun agar total biaya ± 45-55% dari harga jual (margin sehat).
  static final List<({int productId, int bahanId, double qtyUsed})> _resepSeed = [
    // Dimsum Ayam (jual 15.000) → target HPP ~7.200
    (productId: 1, bahanId: 1, qtyUsed: 1),    // kulit 1pcs × 300 = 300
    (productId: 1, bahanId: 2, qtyUsed: 100),  // ayam 100g × 40 = 4.000
    (productId: 1, bahanId: 9, qtyUsed: 5),    // daun bawang 5g × 20 = 100
    (productId: 1, bahanId: 10, qtyUsed: 5),   // bawang putih 5g × 30 = 150
    (productId: 1, bahanId: 5, qtyUsed: 30),   // mayones 30ml × 35 = 1.050
    (productId: 1, bahanId: 4, qtyUsed: 45),   // tapioka 45g × 18 = 810
    // = 6.410

    // Dimsum Udang (jual 18.000) → target HPP ~8.500
    (productId: 2, bahanId: 1, qtyUsed: 1),    // 300
    (productId: 2, bahanId: 3, qtyUsed: 70),   // udang 70g × 90 = 6.300
    (productId: 2, bahanId: 10, qtyUsed: 5),   // 150
    (productId: 2, bahanId: 4, qtyUsed: 40),   // 720
    (productId: 2, bahanId: 9, qtyUsed: 5),    // 100
    // = 7.570

    // Cireng Rujak (jual 10.000) → target HPP ~4.300
    (productId: 3, bahanId: 4, qtyUsed: 120),  // tapioka 120g × 18 = 2.160
    (productId: 3, bahanId: 2, qtyUsed: 40),   // ayam 40g × 40 = 1.600
    (productId: 3, bahanId: 10, qtyUsed: 5),   // 150
    (productId: 3, bahanId: 6, qtyUsed: 15),   // saus rujak 15ml × 25 = 375
    // = 4.285

    // Batagor (jual 12.000) → target HPP ~5.300
    (productId: 4, bahanId: 4, qtyUsed: 100),  // 1.800
    (productId: 4, bahanId: 2, qtyUsed: 60),   // 2.400
    (productId: 4, bahanId: 3, qtyUsed: 20),   // 1.800
    (productId: 4, bahanId: 6, qtyUsed: 20),   // 500
    // = 6.500 → sedikit over, acceptable

    // Dimsum Crab (jual 17.000) → target HPP ~8.200
    (productId: 5, bahanId: 1, qtyUsed: 1),    // 300
    (productId: 5, bahanId: 7, qtyUsed: 40),   // kepiting 40g × 150 = 6.000
    (productId: 5, bahanId: 2, qtyUsed: 30),   // 1.200
    (productId: 5, bahanId: 4, qtyUsed: 30),   // 540
    (productId: 5, bahanId: 10, qtyUsed: 5),   // 150
    // = 8.190

    // Dimsum Jamur (jual 13.000) → target HPP ~5.800
    (productId: 6, bahanId: 1, qtyUsed: 1),    // 300
    (productId: 6, bahanId: 8, qtyUsed: 120),  // jamur 120g × 30 = 3.600
    (productId: 6, bahanId: 4, qtyUsed: 40),   // 720
    (productId: 6, bahanId: 10, qtyUsed: 5),   // 150
    (productId: 6, bahanId: 9, qtyUsed: 5),    // 100
    // = 4.870
  ];

  /// Konversi seed ke ResepItem (id auto dari DB).
  static List<ResepItem> get resepItems => _resepSeed
      .asMap()
      .entries
      .map((e) => ResepItem(
            id: e.key + 1,
            productId: e.value.productId,
            bahanId: e.value.bahanId,
            qtyUsed: e.value.qtyUsed,
          ))
      .toList();

  // ---------------- TRANSAKSI ----------------
  /// Catatan: hppPerUnit disini diisi estimasi yang konsisten dengan resep di atas.
  static final List<Transaction> transactions = [
    Transaction(id: 1, productId: 1, productName: 'Dimsum Ayam', productEmoji: '🥟', quantity: 4, unitPrice: 15000, hppPerUnit: 6410, dateTime: _today(9, 15), note: 'Pelanggan tetap'),
    Transaction(id: 2, productId: 2, productName: 'Dimsum Udang', productEmoji: '🍤', quantity: 3, unitPrice: 18000, hppPerUnit: 7570, dateTime: _today(10, 2)),
    Transaction(id: 3, productId: 3, productName: 'Cireng Rujak', productEmoji: '🫓', quantity: 2, unitPrice: 10000, hppPerUnit: 4285, dateTime: _today(11, 30), note: 'Saus extra'),
    Transaction(id: 4, productId: 5, productName: 'Dimsum Crab', productEmoji: '🦀', quantity: 2, unitPrice: 17000, hppPerUnit: 8190, dateTime: _today(13, 10)),
    Transaction(id: 5, productId: 1, productName: 'Dimsum Ayam', productEmoji: '🥟', quantity: 5, unitPrice: 15000, hppPerUnit: 6410, dateTime: _today(15, 45)),
    Transaction(id: 6, productId: 6, productName: 'Dimsum Jamur', productEmoji: '🍄', quantity: 3, unitPrice: 13000, hppPerUnit: 4870, dateTime: _today(16, 20)),
    Transaction(id: 7, productId: 4, productName: 'Batagor', productEmoji: '🍥', quantity: 3, unitPrice: 12000, hppPerUnit: 6500, dateTime: _today(17, 5)),
    // Kemarin & hari sebelumnya.
    Transaction(id: 8, productId: 2, productName: 'Dimsum Udang', productEmoji: '🍤', quantity: 6, unitPrice: 18000, hppPerUnit: 7570, dateTime: _daysAgo(1, 10)),
    Transaction(id: 9, productId: 1, productName: 'Dimsum Ayam', productEmoji: '🥟', quantity: 8, unitPrice: 15000, hppPerUnit: 6410, dateTime: _daysAgo(1, 14)),
    Transaction(id: 10, productId: 5, productName: 'Dimsum Crab', productEmoji: '🦀', quantity: 4, unitPrice: 17000, hppPerUnit: 8190, dateTime: _daysAgo(2, 12)),
    Transaction(id: 11, productId: 3, productName: 'Cireng Rujak', productEmoji: '🫓', quantity: 5, unitPrice: 10000, hppPerUnit: 4285, dateTime: _daysAgo(2, 16)),
    Transaction(id: 12, productId: 6, productName: 'Dimsum Jamur', productEmoji: '🍄', quantity: 4, unitPrice: 13000, hppPerUnit: 4870, dateTime: _daysAgo(3, 11)),
    Transaction(id: 13, productId: 4, productName: 'Batagor', productEmoji: '🍥', quantity: 6, unitPrice: 12000, hppPerUnit: 6500, dateTime: _daysAgo(4, 13)),
    Transaction(id: 14, productId: 2, productName: 'Dimsum Udang', productEmoji: '🍤', quantity: 7, unitPrice: 18000, hppPerUnit: 7570, dateTime: _daysAgo(5, 15)),
    Transaction(id: 15, productId: 1, productName: 'Dimsum Ayam', productEmoji: '🥟', quantity: 10, unitPrice: 15000, hppPerUnit: 6410, dateTime: _daysAgo(6, 10)),
  ];

  // ---------------- HELPER HPP ----------------
  /// Hitung HPP sebuah produk dari resep + harga bahan (sinkron dengan seeder DB).
  static int hppForProduct(int productId) {
    int sum = 0;
    for (final r in _resepSeed.where((r) => r.productId == productId)) {
      final b = bahans.firstWhere((b) => b.id == r.bahanId);
      sum += (b.buyPrice * r.qtyUsed).round();
    }
    return sum;
  }
}

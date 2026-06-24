import '../models/material_cost.dart';
import '../models/product.dart';
import '../models/stock_item.dart';
import '../models/transaction.dart';

/// 🎀 Data dummy untuk Dimsumia Manager.
/// Dipakai saat first-run seeding (atau ketika database kosong).
class DummyData {
  DummyData._();

  /// Hari ini pada jam tertentu.
  static DateTime _today([int hour = 10, int minute = 0]) {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static DateTime _daysAgo(int days, [int hour = 11]) {
    return _today(hour).subtract(Duration(days: days));
  }

  // ---------------- PRODUK ----------------
  static final List<Product> products = [
    Product(
      id: 1,
      name: 'Dimsum Ayam',
      emoji: '🥟',
      category: 'Steam',
      sellingPrice: 15000,
      hpp: 7500,
      unit: 'pcs',
      description: 'Dimsum ayam klasik dengan saus mayo.',
    ),
    Product(
      id: 2,
      name: 'Dimsum Udang',
      emoji: '🍤',
      category: 'Steam',
      sellingPrice: 18000,
      hpp: 9000,
      unit: 'pcs',
      description: 'Dimsum udang segar, jumbo.',
    ),
    Product(
      id: 3,
      name: 'Cireng Rujak',
      emoji: '🫓',
      category: 'Goreng',
      sellingPrice: 10000,
      hpp: 4500,
      unit: 'porsi',
      description: 'Cireng krispi dengan saus rujak pedas.',
    ),
    Product(
      id: 4,
      name: 'Batagor',
      emoji: '🍥',
      category: 'Goreng',
      sellingPrice: 12000,
      hpp: 5500,
      unit: 'porsi',
      description: 'Batagor khas Bandung, gurih.',
    ),
    Product(
      id: 5,
      name: 'Dimsum Crab',
      emoji: '🦀',
      category: 'Steam',
      sellingPrice: 17000,
      hpp: 8500,
      unit: 'pcs',
      description: 'Dimsum isi kepiting premium.',
    ),
    Product(
      id: 6,
      name: 'Dimsum Jamur',
      emoji: '🍄',
      category: 'Steam',
      sellingPrice: 13000,
      hpp: 6000,
      unit: 'pcs',
      description: 'Dimsum jamur tiram, opsi vegan.',
    ),
  ];

  // ---------------- STOK ----------------
  static final List<StockItem> stocks = [
    StockItem(id: 1, name: 'Kulit Dimsum', unit: 'pcs', quantity: 320, minQuantity: 100, emoji: '🥡', category: 'Bahan'),
    StockItem(id: 2, name: 'Daging Ayam Giling', unit: 'gram', quantity: 850, minQuantity: 500, emoji: '🍗', category: 'Isi'),
    StockItem(id: 3, name: 'Udang Segar', unit: 'gram', quantity: 180, minQuantity: 250, emoji: '🦐', category: 'Isi'),
    StockItem(id: 4, name: 'Tepung Tapioka', unit: 'gram', quantity: 1200, minQuantity: 400, emoji: '🌾', category: 'Bahan'),
    StockItem(id: 5, name: 'Mayones', unit: 'ml', quantity: 0, minQuantity: 200, emoji: '🥛', category: 'Topping'),
    StockItem(id: 6, name: 'Saus Rujak', unit: 'ml', quantity: 250, minQuantity: 200, emoji: '🥫', category: 'Topping'),
    StockItem(id: 7, name: 'Kepiting', unit: 'gram', quantity: 90, minQuantity: 150, emoji: '🦀', category: 'Isi'),
    StockItem(id: 8, name: 'Jamur Tiram', unit: 'gram', quantity: 400, minQuantity: 200, emoji: '🍄', category: 'Isi'),
  ];

  // ---------------- TRANSAKSI ----------------
  static final List<Transaction> transactions = [
    Transaction(
      id: 1,
      productId: 1,
      product: _product(1),
      quantity: 4,
      totalPrice: 60000,
      dateTime: _today(9, 15),
      note: 'Pelanggan tetap',
    ),
    Transaction(
      id: 2,
      productId: 2,
      product: _product(2),
      quantity: 3,
      totalPrice: 54000,
      dateTime: _today(10, 2),
    ),
    Transaction(
      id: 3,
      productId: 3,
      product: _product(3),
      quantity: 2,
      totalPrice: 20000,
      dateTime: _today(11, 30),
      note: 'Pakai saus extra',
    ),
    Transaction(
      id: 4,
      productId: 5,
      product: _product(5),
      quantity: 2,
      totalPrice: 34000,
      dateTime: _today(13, 10),
    ),
    Transaction(
      id: 5,
      productId: 1,
      product: _product(1),
      quantity: 5,
      totalPrice: 75000,
      dateTime: _today(15, 45),
    ),
    Transaction(
      id: 6,
      productId: 6,
      product: _product(6),
      quantity: 3,
      totalPrice: 39000,
      dateTime: _today(16, 20),
    ),
    Transaction(
      id: 7,
      productId: 4,
      product: _product(4),
      quantity: 3,
      totalPrice: 36000,
      dateTime: _today(17, 5),
    ),
    // Kemarin.
    Transaction(
      id: 8,
      productId: 2,
      product: _product(2),
      quantity: 6,
      totalPrice: 108000,
      dateTime: _daysAgo(1, 10),
    ),
    Transaction(
      id: 9,
      productId: 1,
      product: _product(1),
      quantity: 8,
      totalPrice: 120000,
      dateTime: _daysAgo(1, 14),
    ),
    Transaction(
      id: 10,
      productId: 5,
      product: _product(5),
      quantity: 4,
      totalPrice: 68000,
      dateTime: _daysAgo(2, 12),
    ),
    Transaction(
      id: 11,
      productId: 3,
      product: _product(3),
      quantity: 5,
      totalPrice: 50000,
      dateTime: _daysAgo(2, 16),
    ),
    Transaction(
      id: 12,
      productId: 6,
      product: _product(6),
      quantity: 4,
      totalPrice: 52000,
      dateTime: _daysAgo(3, 11),
    ),
    Transaction(
      id: 13,
      productId: 4,
      product: _product(4),
      quantity: 6,
      totalPrice: 72000,
      dateTime: _daysAgo(4, 13),
    ),
    Transaction(
      id: 14,
      productId: 2,
      product: _product(2),
      quantity: 7,
      totalPrice: 126000,
      dateTime: _daysAgo(5, 15),
    ),
    Transaction(
      id: 15,
      productId: 1,
      product: _product(1),
      quantity: 10,
      totalPrice: 150000,
      dateTime: _daysAgo(6, 10),
    ),
  ];

  // ---------------- HPP MATERIALS ----------------
  static final List<MaterialCost> materials = [
    MaterialCost(id: 1, productId: 1, name: 'Kulit Dimsum', cost: 1500, emoji: '🥡'),
    MaterialCost(id: 2, productId: 1, name: 'Daging Ayam', cost: 4000, emoji: '🍗'),
    MaterialCost(id: 3, productId: 1, name: 'Mayones', cost: 2000, emoji: '🥛'),
    MaterialCost(id: 4, productId: 2, name: 'Kulit Dimsum', cost: 1500, emoji: '🥡'),
    MaterialCost(id: 5, productId: 2, name: 'Udang', cost: 5500, emoji: '🦐'),
    MaterialCost(id: 6, productId: 2, name: 'Bumbu', cost: 2000, emoji: '🧂'),
    MaterialCost(id: 7, productId: 3, name: 'Tepung Tapioka', cost: 2000, emoji: '🌾'),
    MaterialCost(id: 8, productId: 3, name: 'Saus Rujak', cost: 2500, emoji: '🥫'),
    MaterialCost(id: 9, productId: 4, name: 'Tepung', cost: 2500, emoji: '🌾'),
    MaterialCost(id: 10, productId: 4, name: 'Isi Tahu', cost: 3000, emoji: '🫘'),
    MaterialCost(id: 11, productId: 5, name: 'Kulit Dimsum', cost: 1500, emoji: '🥡'),
    MaterialCost(id: 12, productId: 5, name: 'Kepiting', cost: 6000, emoji: '🦀'),
    MaterialCost(id: 13, productId: 5, name: 'Bumbu', cost: 1000, emoji: '🧂'),
    MaterialCost(id: 14, productId: 6, name: 'Kulit Dimsum', cost: 1500, emoji: '🥡'),
    MaterialCost(id: 15, productId: 6, name: 'Jamur Tiram', cost: 3500, emoji: '🍄'),
    MaterialCost(id: 16, productId: 6, name: 'Bumbu', cost: 1000, emoji: '🧂'),
  ];

  static Product _product(int id) => products.firstWhere((p) => p.id == id);
}

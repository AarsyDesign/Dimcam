import 'product.dart';

/// 🧾 Item transaksi penjualan (1 transaksi = 1 produk dengan qty tertentu).
class Transaction {
  Transaction({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.totalPrice,
    required this.dateTime,
    this.note,
  });

  final int id;
  final int productId;
  final Product product;
  final int quantity;
  final int totalPrice; // qty * sellingPrice
  final DateTime dateTime;
  final String? note;

  /// Laba dari transaksi ini = qty * (sellingPrice - hpp).
  int get profit => quantity * (product.sellingPrice - product.hpp);

  factory Transaction.fromMap(Map<String, dynamic> map, Product product) => Transaction(
        id: map['id'] as int,
        productId: map['product_id'] as int,
        product: product,
        quantity: (map['quantity'] as num).toInt(),
        totalPrice: (map['total_price'] as num).toInt(),
        dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
        note: map['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'quantity': quantity,
        'total_price': totalPrice,
        'date_time': dateTime.millisecondsSinceEpoch,
        'note': note,
      };
}

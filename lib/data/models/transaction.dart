/// 🧾 Item transaksi penjualan (1 transaksi = 1 produk dengan qty tertentu).
///
/// Menyimpan snapshot [hppPerUnit] saat transaksi tercatat agar profit
/// tetap akurat secara historis walau resep/HPP berubah di kemudian hari.
class Transaction {
  Transaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productEmoji,
    required this.quantity,
    required this.unitPrice,
    required this.hppPerUnit,
    required this.dateTime,
    this.note,
  });

  final int id;
  final int productId;
  final String productName;
  final String productEmoji;
  final int quantity;
  final int unitPrice; // harga jual per unit saat transaksi
  final int hppPerUnit; // HPP per unit saat transaksi (snapshot)
  final DateTime dateTime;
  final String? note;

  int get totalPrice => quantity * unitPrice;
  int get totalCost => quantity * hppPerUnit;
  int get profit => totalPrice - totalCost;

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as int,
        productId: map['product_id'] as int,
        productName: map['product_name'] as String,
        productEmoji: map['product_emoji'] as String? ?? '🥟',
        quantity: (map['quantity'] as num).toInt(),
        unitPrice: (map['unit_price'] as num).toInt(),
        hppPerUnit: (map['hpp_per_unit'] as num).toInt(),
        dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
        note: map['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'product_emoji': productEmoji,
        'quantity': quantity,
        'unit_price': unitPrice,
        'hpp_per_unit': hppPerUnit,
        'date_time': dateTime.millisecondsSinceEpoch,
        'note': note,
      };
}

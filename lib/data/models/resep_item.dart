/// 📝 Item resep produk — menghubungkan produk dengan bahan & jumlah pemakaian.
class ResepItem {
  ResepItem({
    required this.id,
    required this.productId,
    required this.bahanId,
    required this.qtyUsed,
  });

  final int id;
  final int productId;
  final int bahanId;
  final double qtyUsed; // jumlah pemakaian dalam satuan bahan

  factory ResepItem.fromMap(Map<String, dynamic> map) => ResepItem(
        id: map['id'] as int,
        productId: map['product_id'] as int,
        bahanId: map['bahan_id'] as int,
        qtyUsed: (map['qty_used'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'bahan_id': bahanId,
        'qty_used': qtyUsed,
      };

  ResepItem copyWith({
    int? id,
    int? productId,
    int? bahanId,
    double? qtyUsed,
  }) =>
      ResepItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        bahanId: bahanId ?? this.bahanId,
        qtyUsed: qtyUsed ?? this.qtyUsed,
      );
}

/// Pasangan resep + detail bahan untuk kalkulasi & tampilan.
class ResepLine {
  const ResepLine({required this.item, required this.bahanName, required this.bahanUnit, required this.subtotal});
  final ResepItem item;
  final String bahanName;
  final String bahanUnit;
  final int subtotal; // buyPrice * qtyUsed

  bool get isFractional => item.qtyUsed != item.qtyUsed.roundToDouble();
}

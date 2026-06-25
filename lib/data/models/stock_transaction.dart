enum StockTransactionType { purchase, production, adjustment }

class StockTransaction {
  StockTransaction({
    required this.id,
    required this.bahanId,
    required this.bahanName,
    required this.type,
    required this.quantity,
    required this.note,
    required this.dateTime,
    this.productId,
    this.productName,
  });

  final int id;
  final int bahanId;
  final String bahanName;
  final StockTransactionType type;
  final double quantity;
  final String? note;
  final DateTime dateTime;
  final int? productId;
  final String? productName;

  bool get isInbound => quantity > 0;
  bool get isOutbound => quantity < 0;

  factory StockTransaction.fromMap(Map<String, dynamic> map) {
    return StockTransaction(
      id: map['id'] as int,
      bahanId: map['bahan_id'] as int,
      bahanName: map['bahan_name'] as String,
      type: StockTransactionType.values[map['type'] as int],
      quantity: (map['quantity'] as num).toDouble(),
      note: map['note'] as String?,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
      productId: map['product_id'] as int?,
      productName: map['product_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'bahan_id': bahanId,
        'bahan_name': bahanName,
        'type': type.index,
        'quantity': quantity,
        'note': note,
        'date_time': dateTime.millisecondsSinceEpoch,
        'product_id': productId,
        'product_name': productName,
      };

  String get typeLabel => switch (type) {
        StockTransactionType.purchase => 'Pembelian',
        StockTransactionType.production => 'Produksi',
        StockTransactionType.adjustment => 'Penyesuaian',
      };
}

class Production {
  Production({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productEmoji,
    required this.quantity,
    required this.totalCost,
    required this.dateTime,
    this.note,
  });

  final int id;
  final int productId;
  final String productName;
  final String productEmoji;
  final int quantity;
  final int totalCost;
  final DateTime dateTime;
  final String? note;

  factory Production.fromMap(Map<String, dynamic> map) {
    return Production(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      productEmoji: map['product_emoji'] as String? ?? '🥟',
      quantity: (map['quantity'] as num).toInt(),
      totalCost: (map['total_cost'] as num).toInt(),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'product_emoji': productEmoji,
        'quantity': quantity,
        'total_cost': totalCost,
        'date_time': dateTime.millisecondsSinceEpoch,
        'note': note,
      };
}

class ProductionDetail {
  ProductionDetail({
    required this.id,
    required this.productionId,
    required this.bahanId,
    required this.bahanName,
    required this.bahanEmoji,
    required this.qtyUsed,
    required this.unit,
    required this.cost,
  });

  final int id;
  final int productionId;
  final int bahanId;
  final String bahanName;
  final String? bahanEmoji;
  final double qtyUsed;
  final String unit;
  final int cost;

  factory ProductionDetail.fromMap(Map<String, dynamic> map) {
    return ProductionDetail(
      id: map['id'] as int,
      productionId: map['production_id'] as int,
      bahanId: map['bahan_id'] as int,
      bahanName: map['bahan_name'] as String,
      bahanEmoji: map['bahan_emoji'] as String?,
      qtyUsed: (map['qty_used'] as num).toDouble(),
      unit: map['unit'] as String,
      cost: (map['cost'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'production_id': productionId,
        'bahan_id': bahanId,
        'bahan_name': bahanName,
        'bahan_emoji': bahanEmoji,
        'qty_used': qtyUsed,
        'unit': unit,
        'cost': cost,
      };
}

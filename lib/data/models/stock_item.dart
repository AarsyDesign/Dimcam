/// 📦 Item stok bahan baku / produk.
class StockItem {
  StockItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minQuantity,
    this.emoji,
    this.category = 'Bahan',
  });

  final int id;
  final String name;
  final String unit; // "gram", "pcs", "ml"
  final double quantity;
  final double minQuantity; // batas stok menipis
  final String? emoji;
  final String category;

  bool get isLow => quantity <= minQuantity && quantity > 0;
  bool get isOut => quantity <= 0;
  bool get isSafe => quantity > minQuantity;

  StockStatus get status {
    if (isOut) return StockStatus.out;
    if (isLow) return StockStatus.low;
    return StockStatus.safe;
  }

  factory StockItem.fromMap(Map<String, dynamic> map) => StockItem(
        id: map['id'] as int,
        name: map['name'] as String,
        unit: map['unit'] as String? ?? 'pcs',
        quantity: (map['quantity'] as num).toDouble(),
        minQuantity: (map['min_quantity'] as num).toDouble(),
        emoji: map['emoji'] as String?,
        category: map['category'] as String? ?? 'Bahan',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unit': unit,
        'quantity': quantity,
        'min_quantity': minQuantity,
        'emoji': emoji,
        'category': category,
      };

  StockItem copyWith({
    int? id,
    String? name,
    String? unit,
    double? quantity,
    double? minQuantity,
    String? emoji,
    String? category,
  }) =>
      StockItem(
        id: id ?? this.id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        quantity: quantity ?? this.quantity,
        minQuantity: minQuantity ?? this.minQuantity,
        emoji: emoji ?? this.emoji,
        category: category ?? this.category,
      );
}

enum StockStatus { safe, low, out }

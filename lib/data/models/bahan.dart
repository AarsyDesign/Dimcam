/// 🧂 Master Bahan — sekaligus menyimpan stok & harga beli.
///
/// Harga beli [`buyPrice`] adalah harga **per 1 satuan** [`unit`].
/// Contoh: unit "gram", buyPrice 35 → Rp 35/gram.
/// Resep produk memakai kuantitas dalam satuan yang sama.
class Bahan {
  Bahan({
    required this.id,
    required this.name,
    required this.unit,
    required this.buyPrice,
    required this.stock,
    required this.minStock,
    this.emoji,
    this.category = 'Bahan',
  });

  final int id;
  final String name;
  final String unit; // "gram", "pcs", "ml"
  final int buyPrice; // harga per 1 unit
  final double stock; // jumlah stok dalam unit
  final double minStock; // batas stok menipis
  final String? emoji;
  final String category;

  bool get isLow => stock <= minStock && stock > 0;
  bool get isOut => stock <= 0;
  bool get isSafe => stock > minStock;

  StockStatus get status {
    if (isOut) return StockStatus.out;
    if (isLow) return StockStatus.low;
    return StockStatus.safe;
  }

  factory Bahan.fromMap(Map<String, dynamic> map) => Bahan(
        id: map['id'] as int,
        name: map['name'] as String,
        unit: map['unit'] as String? ?? 'pcs',
        buyPrice: (map['buy_price'] as num).toInt(),
        stock: (map['stock'] as num).toDouble(),
        minStock: (map['min_stock'] as num).toDouble(),
        emoji: map['emoji'] as String?,
        category: map['category'] as String? ?? 'Bahan',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unit': unit,
        'buy_price': buyPrice,
        'stock': stock,
        'min_stock': minStock,
        'emoji': emoji,
        'category': category,
      };

  Bahan copyWith({
    int? id,
    String? name,
    String? unit,
    int? buyPrice,
    double? stock,
    double? minStock,
    String? emoji,
    String? category,
  }) =>
      Bahan(
        id: id ?? this.id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        buyPrice: buyPrice ?? this.buyPrice,
        stock: stock ?? this.stock,
        minStock: minStock ?? this.minStock,
        emoji: emoji ?? this.emoji,
        category: category ?? this.category,
      );
}

enum StockStatus { safe, low, out }

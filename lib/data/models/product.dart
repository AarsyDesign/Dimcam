/// 🥟 Model produk dimsum.
class Product {
  Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.sellingPrice,
    required this.hpp,
    required this.unit,
    this.description,
  });

  final int id;
  final String name;
  final String emoji;
  final String category;
  final int sellingPrice; // harga jual per pcs / porsi
  final int hpp; // harga pokok produksi
  final String unit; // "pcs", "porsi"
  final String? description;

  /// Margin keuntungan absolut.
  int get margin => sellingPrice - hpp;

  /// Margin keuntungan dalam persen.
  double get marginPercent => sellingPrice == 0 ? 0 : (margin / sellingPrice) * 100;

  /// Inisial untuk avatar.
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'D';

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as int,
        name: map['name'] as String,
        emoji: map['emoji'] as String? ?? '🥟',
        category: map['category'] as String? ?? 'Dimsum',
        sellingPrice: (map['selling_price'] as num).toInt(),
        hpp: (map['hpp'] as num).toInt(),
        unit: map['unit'] as String? ?? 'pcs',
        description: map['description'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'category': category,
        'selling_price': sellingPrice,
        'hpp': hpp,
        'unit': unit,
        'description': description,
      };

  Product copyWith({
    int? id,
    String? name,
    String? emoji,
    String? category,
    int? sellingPrice,
    int? hpp,
    String? unit,
    String? description,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        category: category ?? this.category,
        sellingPrice: sellingPrice ?? this.sellingPrice,
        hpp: hpp ?? this.hpp,
        unit: unit ?? this.unit,
        description: description ?? this.description,
      );
}

/// 🧮 Komponen bahan penyusun HPP (harga pokok produksi) sebuah produk.
class MaterialCost {
  MaterialCost({
    required this.id,
    required this.productId,
    required this.name,
    required this.cost,
    this.emoji,
  });

  final int id;
  final int productId;
  final String name; // mis. "Tepung", "Isi Ayam"
  final int cost; // biaya kontribusi ke HPP (Rupiah)
  final String? emoji;

  factory MaterialCost.fromMap(Map<String, dynamic> map) => MaterialCost(
        id: map['id'] as int,
        productId: map['product_id'] as int,
        name: map['name'] as String,
        cost: (map['cost'] as num).toInt(),
        emoji: map['emoji'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'cost': cost,
        'emoji': emoji,
      };
}

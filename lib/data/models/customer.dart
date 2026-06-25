class Customer {
  Customer({
    required this.id,
    required this.name,
    this.whatsapp,
    this.address,
    this.note,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? whatsapp;
  final String? address;
  final String? note;
  final DateTime? createdAt;

  /// Diisi dari JOIN query — bukan kolom database.
  int totalTransactions = 0;
  int totalPurchase = 0;
  String? favoriteProduct;
  String? favoriteProductEmoji;

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'] as int,
        name: map['name'] as String,
        whatsapp: map['whatsapp'] as String?,
        address: map['address'] as String?,
        note: map['note'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'whatsapp': whatsapp,
        'address': address,
        'note': note,
        'created_at': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
      };

  Customer copyWith({
    int? id,
    String? name,
    String? whatsapp,
    String? address,
    String? note,
    DateTime? createdAt,
  }) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        whatsapp: whatsapp ?? this.whatsapp,
        address: address ?? this.address,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );
}

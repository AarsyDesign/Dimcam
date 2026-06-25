enum DebtStatus { unpaid, paid }

class Debt {
  Debt({
    required this.id,
    required this.customerName,
    this.whatsapp,
    required this.amount,
    required this.dateTime,
    required this.status,
    this.note,
  });

  final int id;
  final String customerName;
  final String? whatsapp;
  final int amount;
  final DateTime dateTime;
  final DebtStatus status;
  final String? note;

  bool get isPaid => status == DebtStatus.paid;
  bool get isUnpaid => status == DebtStatus.unpaid;

  bool get isOverdue {
    if (isPaid) return false;
    return dateTime.isBefore(DateTime.now().subtract(const Duration(days: 30)));
  }

  String get statusLabel => isPaid ? 'Lunas' : 'Belum Lunas';

  factory Debt.fromMap(Map<String, dynamic> map) => Debt(
        id: map['id'] as int,
        customerName: map['customer_name'] as String,
        whatsapp: map['whatsapp'] as String?,
        amount: (map['amount'] as num).toInt(),
        dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time'] as int),
        status: DebtStatus.values[map['status'] as int],
        note: map['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'customer_name': customerName,
        'whatsapp': whatsapp,
        'amount': amount,
        'date_time': dateTime.millisecondsSinceEpoch,
        'status': status.index,
        'note': note,
      };

  Debt copyWith({
    int? id,
    String? customerName,
    String? whatsapp,
    int? amount,
    DateTime? dateTime,
    DebtStatus? status,
    String? note,
  }) =>
      Debt(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        whatsapp: whatsapp ?? this.whatsapp,
        amount: amount ?? this.amount,
        dateTime: dateTime ?? this.dateTime,
        status: status ?? this.status,
        note: note ?? this.note,
      );
}

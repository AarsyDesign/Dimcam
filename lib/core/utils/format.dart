import 'package:intl/intl.dart';

/// 💴 Helper format mata uang Rupiah & angka.
class Format {
  Format._();

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _rupiahShort = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  static final NumberFormat _number = NumberFormat.decimalPattern('id_ID');

  /// Format lengkap: "Rp 25.000"
  static String rupiah(num value) => _rupiah.format(value);

  /// Format ringkas untuk statistik: "Rp 1,2 jt", "Rp 950 rb".
  static String rupiahShort(num value) => _rupiahShort.format(value);

  /// Format angka biasa: "1.234"
  static String number(num value) => _number.format(value);

  /// Persentase: "32%"
  static String percent(num value, {int digits = 0}) =>
      '${value.toStringAsFixed(digits)}%';
}

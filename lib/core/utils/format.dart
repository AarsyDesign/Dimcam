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

  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  static const List<String> _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  /// Format lengkap: "Rp 25.000"
  static String rupiah(num value) => _rupiah.format(value);

  /// Format ringkas untuk statistik: "Rp 1,2 jt", "Rp 950 rb".
  static String rupiahShort(num value) => _rupiahShort.format(value);

  /// Format angka biasa: "1.234"
  static String number(num value) => _number.format(value);

  /// Persentase: "32%"
  static String percent(num value, {int digits = 0}) =>
      '${value.toStringAsFixed(digits)}%';

  // --- Tanggal tanpa dependensi locale intl ---

  /// "Senin, 1 Januari 2024"
  static String dateLong(DateTime d) =>
      '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  /// "1 Januari 2024"
  static String dateLongNoDay(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// "1 Jan 2024"
  static String dateMedium(DateTime d) =>
      '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  /// "Senin, 1 Jan 2024 · 14:30"
  static String dateTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${_days[d.weekday - 1]}, ${d.day} ${_monthsShort[d.month - 1]} ${d.year} · $h:$m';
  }

  /// "1 Jan 2024 14:30"
  static String dateMediumTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_monthsShort[d.month - 1]} ${d.year} $h:$m';
  }

  /// "1 Jan"
  static String dateShort(DateTime d) =>
      '${d.day} ${_monthsShort[d.month - 1]}';

  /// "Januari 2024"
  static String monthYear(DateTime d) =>
      '${_months[d.month - 1]} ${d.year}';

  /// "2024"
  static String yearOnly(DateTime d) => '${d.year}';

  /// Satu huruf pertama nama hari: "S" untuk Senin
  static String dayAbbr(DateTime d) => _days[d.weekday - 1][0];
}

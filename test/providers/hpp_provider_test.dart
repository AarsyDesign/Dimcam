import 'package:flutter_test/flutter_test.dart';
import 'package:dimsumia_manager/data/models/bahan.dart';
import 'package:dimsumia_manager/providers/hpp_provider.dart';

void main() {
  group('HppProvider.previewHpp', () {
    late HppProvider provider;
    late List<Bahan> bahans;

    setUp(() {
      provider = HppProvider();
      bahans = [
        Bahan(
          id: 1, name: 'Tepung', buyPrice: 10000, unit: 'kg',
          stock: 10, minStock: 2, category: 'Bahan Kering',
        ),
        Bahan(
          id: 2, name: 'Minyak', buyPrice: 20000, unit: 'liter',
          stock: 5, minStock: 1, category: 'Bahan Basah',
        ),
      ];
    });

    test('hitung total biaya dari 2 bahan', () {
      final lines = [
        (bahanId: 1, qty: 0.5),  // 0.5 kg tepung = 10000 * 0.5 = 5000
        (bahanId: 2, qty: 0.25), // 0.25 liter minyak = 20000 * 0.25 = 5000
      ];
      expect(provider.previewHpp(lines, bahans), 10000);
    });

    test('return 0 jika lines kosong', () {
      expect(provider.previewHpp([], bahans), 0);
    });

    test('tidak crash jika bahanId tidak ditemukan (fallback ke first)', () {
      final lines = [
        (bahanId: 999, qty: 1.0),
      ];
      expect(provider.previewHpp(lines, bahans), 10000);
    });
  });
}

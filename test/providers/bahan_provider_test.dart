import 'package:flutter_test/flutter_test.dart';
import 'package:dimsumia_manager/data/models/bahan.dart';
import 'package:dimsumia_manager/providers/bahan_provider.dart';

void main() {
  group('BahanProvider.filteredItems', () {
    late BahanProvider provider;

    setUp(() {
      provider = BahanProvider(autoLoad: false);
      provider.items = [
        Bahan(
          id: 1, name: 'Tepung Terigu', buyPrice: 10000, unit: 'kg',
          stock: 10, minStock: 2, category: 'Bahan Kering',
        ),
        Bahan(
          id: 2, name: 'Minyak Goreng', buyPrice: 20000, unit: 'liter',
          stock: 5, minStock: 1, category: 'Bahan Basah',
        ),
        Bahan(
          id: 3, name: 'Garam', buyPrice: 5000, unit: 'kg',
          stock: 2, minStock: 1, category: 'Bumbu',
        ),
      ];
    });

    test('return all items when query kosong', () {
      provider.setSearchQuery('');
      expect(provider.filteredItems.length, 3);
    });

    test('filter by nama (case insensitive)', () {
      provider.setSearchQuery('tepung');
      expect(provider.filteredItems.length, 1);
      expect(provider.filteredItems.first.name, 'Tepung Terigu');
    });

    test('filter by nama partial match', () {
      provider.setSearchQuery('goreng');
      expect(provider.filteredItems.length, 1);
    });

    test('filter by kategori', () {
      provider.setSearchQuery('bumbu');
      expect(provider.filteredItems.length, 1);
      expect(provider.filteredItems.first.name, 'Garam');
    });

    test('return kosong jika tidak ada match', () {
      provider.setSearchQuery('xyz');
      expect(provider.filteredItems, isEmpty);
    });
  });
}

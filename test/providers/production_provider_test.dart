import 'package:flutter_test/flutter_test.dart';
import 'package:dimsumia_manager/data/models/production.dart';
import 'package:dimsumia_manager/providers/production_provider.dart';

void main() {
  group('ProductionProvider.filteredItems', () {
    late ProductionProvider provider;

    setUp(() {
      provider = ProductionProvider(autoLoad: false);
      provider.items = [
        Production(
          id: 1, productId: 1, productName: 'Dimsum Ayam', productEmoji: '🥟',
          quantity: 10, totalCost: 50000, dateTime: DateTime(2026, 6, 30),
          note: 'Pesenan Bu Sari',
        ),
        Production(
          id: 2, productId: 2, productName: 'Lumpia Udang', productEmoji: '🥟',
          quantity: 20, totalCost: 80000, dateTime: DateTime(2026, 6, 29),
        ),
      ];
    });

    test('return all items when query kosong', () {
      provider.setSearchQuery('');
      expect(provider.filteredItems.length, 2);
    });

    test('filter by product name', () {
      provider.setSearchQuery('ayam');
      expect(provider.filteredItems.length, 1);
      expect(provider.filteredItems.first.productName, 'Dimsum Ayam');
    });

    test('filter by note', () {
      provider.setSearchQuery('sari');
      expect(provider.filteredItems.length, 1);
    });

    test('return kosong jika tidak match', () {
      provider.setSearchQuery('takada');
      expect(provider.filteredItems, isEmpty);
    });
  });
}

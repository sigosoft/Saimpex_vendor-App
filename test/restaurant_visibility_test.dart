import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/model/restaurant_menu_items_model.dart';

void main() {
  test('catalog rows carry the hide / unhide state (#132)', () {
    final hidden = RestaurantMenuItemData.fromJson({
      'id': 12,
      'name_en': 'Burger',
      'price': '120',
      'available_status': 1,
      'is_hidden': true,
      'hidden_until': '2026-11-02T18:00:00+00:00',
      'hidden_forever': false,
    });
    expect(hidden.id, 12);
    expect(hidden.visibility.isHidden, isTrue);
    expect(hidden.visibility.hiddenUntil, isNotNull);
    expect(hidden.visibility.hiddenForever, isFalse);

    final forever = RestaurantMenuItemData.fromJson({'id': 13, 'is_hidden': 1, 'hidden_until': null, 'hidden_forever': 1});
    expect(forever.visibility.isHidden, isTrue);
    expect(forever.visibility.hiddenForever, isTrue);

    final visible = RestaurantMenuItemData.fromJson({'id': 14, 'name_en': 'Fries'});
    expect(visible.visibility.isHidden, isFalse);
  });
}

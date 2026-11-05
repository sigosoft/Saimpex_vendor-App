import 'package:flutter_test/flutter_test.dart';
import 'package:saimpex_vendor/configs/store_endpoints.dart';

void main() {
  test('local store (11) uses the localStore* twin', () {
    expect(
      StoreEndpoints.forVendorType('groceryMenuItems', '11'),
      'localStoreMenuItems',
    );
    expect(
      StoreEndpoints.forVendorType(
        'https://dev.example/api/vendorapp/acceptGroceryOrder?order_id=5',
        '11',
      ),
      'https://dev.example/api/vendorapp/acceptLocalStoreOrder?order_id=5',
    );
    expect(
      StoreEndpoints.forVendorType('vendorapp/updateGrocerytItemStock', '11'),
      'vendorapp/updateLocalStoretItemStock',
    );
  });

  test('other vendor types and other endpoints are unchanged', () {
    expect(
      StoreEndpoints.forVendorType('groceryMenuItems', '2'),
      'groceryMenuItems',
    );
    expect(
      StoreEndpoints.forVendorType('groceryMenuItems', null),
      'groceryMenuItems',
    );
    expect(StoreEndpoints.forVendorType('home', '11'), 'home');
    expect(
      StoreEndpoints.forVendorType('restaurantOrderDetail', '11'),
      'restaurantOrderDetail',
    );
  });

  test('local store keys: requests renamed, replies renamed back', () {
    expect(StoreEndpoints.toLocalStoreKey('grocery_menu_id'), 'local_store_menu_id');
    expect(StoreEndpoints.toLocalStoreKey('grocery_tag_id'), 'local_store_tag_id');
    expect(StoreEndpoints.toLocalStoreKey('menu_item_id'), 'menu_item_id');
    final reply = StoreEndpoints.toGroceryKeys({
      'status': true,
      'data': {
        'local_store_menu_items': {
          'data': [
            {'local_store_menu_id': 1, 'local_store_id': 60, 'name_en': 'Smartphone'},
          ],
        },
      },
    });
    expect(reply, isA<Map<String, dynamic>>());
    expect(reply['data'], isA<Map<String, dynamic>>());
    final row = (reply['data']['grocery_menu_items']['data'] as List).first as Map<String, dynamic>;
    expect(row['grocery_menu_id'], 1);
    expect(row['local_store_id'], 60);
    expect(row['name_en'], 'Smartphone');
    expect(StoreEndpoints.isSwapped('groceryMenuItems', '11'), isTrue);
    expect(StoreEndpoints.isSwapped('groceryMenuItems', '2'), isFalse);
  });
}

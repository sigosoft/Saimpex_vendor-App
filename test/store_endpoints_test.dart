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
}

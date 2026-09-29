import 'package:get/get.dart';
import 'package:saimpex_vendor/water/model/inventory_product.dart';

class WaterInventoryController extends GetxController {
  int selectedFilter = 0;

  final products = <InventoryProduct>[
    const InventoryProduct(
      id: '# 33',
      name: 'Drinking Water 10L',
      price: '50.00 MRU',
      originalPrice: '100.00 MRU',
      bottles: 300,
      maxBottles: 400,
      status: InventoryStockStatus.inStock,
    ),
    const InventoryProduct(
      id: '# 34',
      name: 'Drinking Water 19L',
      price: '50.00 MRU',
      originalPrice: '100.00 MRU',
      bottles: 0,
      maxBottles: 400,
      status: InventoryStockStatus.outOfStock,
    ),
  ];

  void selectFilter(int index) {
    selectedFilter = index;
    update();
  }

  void markOutOfStock(int index) {
    final product = products[index];
    products[index] = product.copyWith(
      bottles: 0,
      status: InventoryStockStatus.outOfStock,
    );
    update();
  }

  void markAvailable(int index) {
    final product = products[index];
    products[index] = product.copyWith(
      bottles: product.bottles > 0 ? product.bottles : 50,
      status: InventoryStockStatus.inStock,
    );
    update();
  }

  void updateQuantity(int index, int quantity) {
    final product = products[index];
    products[index] = product.copyWith(
      bottles: quantity,
      status: quantity == 0
          ? InventoryStockStatus.outOfStock
          : quantity <= 20
              ? InventoryStockStatus.lowStock
              : InventoryStockStatus.inStock,
    );
    update();
  }

  void removeAt(int index) {
    products.removeAt(index);
    update();
  }
}

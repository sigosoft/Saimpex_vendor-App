enum InventoryStockStatus { inStock, lowStock, outOfStock }

class InventoryProduct {
  const InventoryProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.bottles,
    required this.maxBottles,
    required this.status,
  });

  final String id;
  final String name;
  final String price;
  final String originalPrice;
  final int bottles;
  final int maxBottles;
  final InventoryStockStatus status;

  InventoryProduct copyWith({
    int? bottles,
    InventoryStockStatus? status,
  }) {
    return InventoryProduct(
      id: id,
      name: name,
      price: price,
      originalPrice: originalPrice,
      bottles: bottles ?? this.bottles,
      maxBottles: maxBottles,
      status: status ?? this.status,
    );
  }
}

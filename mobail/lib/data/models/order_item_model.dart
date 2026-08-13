class OrderItem {
  final int id;
  final int productId;
  final int variantId;
  final String productName;
  final String variantName;
  final String? variantColor;
  final String? variantSize;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? storeName;
  final String? storeAddress;

  OrderItem({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    this.variantColor,
    this.variantSize,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.storeName,
    this.storeAddress,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      variantId: json['variant_id'] as int,
      productName: json['product_name'] as String,
      variantName: json['variant_name'] as String,
      variantColor: json['variant_color'] as String?,
      variantSize: json['variant_size'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      storeName: json['store_name'] as String?,
      storeAddress: json['store_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'variant_id': variantId,
      'product_name': productName,
      'variant_name': variantName,
      'variant_color': variantColor,
      'variant_size': variantSize,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'store_name': storeName,
      'store_address': storeAddress,
    };
  }
}

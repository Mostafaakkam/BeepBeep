import 'cart_product_model.dart';
import 'product_variant_model.dart';

class CartItem {
  final int id;
  final CartProduct product;
  final ProductVariant variant;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  CartItem({
    required this.id,
    required this.product,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      product: CartProduct.fromJson(json['product'] as Map<String, dynamic>),
      variant: ProductVariant.fromJson(json['variant'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'variant': variant.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}

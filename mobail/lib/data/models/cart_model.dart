import 'cart_item_model.dart';

class Cart {
  final List<CartItem> items;
  final int itemsCount;
  final double subtotal;
  final double total;

  Cart({
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.total,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return Cart(
      items: itemsList.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList(),
      itemsCount: json['items_count'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'items_count': itemsCount,
      'subtotal': subtotal,
      'total': total,
    };
  }
  
  bool get isEmpty => items.isEmpty;
}

class ProductVariant {
  final int id;
  final String? color;
  final String? size;
  final double price;
  final int stock;

  ProductVariant({
    required this.id,
    this.color,
    this.size,
    required this.price,
    required this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int,
      color: json['color'] as String?,
      size: json['size'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
    };
  }
}

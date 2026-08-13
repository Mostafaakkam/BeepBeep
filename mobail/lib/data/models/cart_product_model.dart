class CartProduct {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? storeName;
  final String? storeAddress;

  CartProduct({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.storeName,
    this.storeAddress,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      storeName: json['store_name'] as String?,
      storeAddress: json['store_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'store_name': storeName,
      'store_address': storeAddress,
    };
  }
}

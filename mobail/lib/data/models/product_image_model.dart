class ProductImage {
  final int id;
  final String imagePath;

  ProductImage({
    required this.id,
    required this.imagePath,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int,
      imagePath: json['image_path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
    };
  }
}

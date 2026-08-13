class Store {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String? coverImage;
  final String? address;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.coverImage,
    this.address,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      coverImage: json['cover_image'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'cover_image': coverImage,
      'address': address,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

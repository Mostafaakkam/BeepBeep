class Store {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String? coverImage;
  final String? address;
  final String? phone;
  // Store Owner Dashboard: only present on owner-scoped responses (e.g.
  // GET /api/stores/mine -- see storeRepository.findByOwnerId). The public
  // GET /api/stores / GET /api/stores/:id list omits it on the "all active
  // stores" list (findAllActive never selects it either), so this stays
  // nullable and every existing call site that never reads it is unaffected.
  final String? status;
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
    this.status,
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
      status: json['status'] as String?,
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
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Stabilization fix (2026-08-30): the live `addresses` table only ever had
// (id, user_id, city, area, details, is_default) -- it never had label,
// recipient_name, phone, address, created_at, or updated_at, which this
// model used to assume (every address endpoint was returning 500 against
// the real database as a result). This model now represents exactly the
// columns that actually exist. Checkout is unaffected by this change: the
// order-creation flow (checkout_page.dart / orderController.js) collects
// customer_name, customer_phone, and delivery_address directly at checkout
// time and does not read an order from a saved AddressModel -- the one
// place checkout does read AddressModel fields (its "pick a saved address"
// dropdown) was updated separately to use city/details instead of the
// removed label/recipientName/phone/address fields.
class AddressModel {
  final int id;
  final int userId;
  final String city;
  final String? area;
  final String? details;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.city,
    this.area,
    this.details,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      city: json['city'] as String? ?? '',
      area: json['area'] as String?,
      details: json['details'] as String?,
      isDefault: (json['is_default'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'city': city,
      'area': area,
      'details': details,
      'is_default': isDefault ? 1 : 0,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'city': city,
      'area': area,
      'details': details,
      'is_default': isDefault,
    };
  }

  AddressModel copyWith({
    int? id,
    int? userId,
    String? city,
    String? area,
    String? details,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      city: city ?? this.city,
      area: area ?? this.area,
      details: details ?? this.details,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class RegisterResponse {
  final bool success;
  final String message;
  final UserData? data;
  
  RegisterResponse({
    required this.success,
    required this.message,
    this.data,
  });
  
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? UserData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserData {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String createdAt;
  
  UserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.createdAt,
  });
  
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

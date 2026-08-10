import 'register_response.dart';

class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'password': password,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;
  
  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginData {
  final UserData user;
  final String token;
  
  LoginData({
    required this.user,
    required this.token,
  });
  
  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

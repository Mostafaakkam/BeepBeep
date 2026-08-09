class RegisterRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  
  RegisterRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };
  }
}

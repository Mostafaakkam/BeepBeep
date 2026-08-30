// Store Owner Dashboard: the DB-fresh identity returned by GET /api/auth/me
// (see backend/src/services/authService.js#getCurrentUser). Deliberately a
// separate, smaller model from UserData (register_response.dart) -- this
// endpoint returns only {userId, role}, not the full profile shape returned
// by register/login.
class CurrentUser {
  final int userId;
  final String role;

  CurrentUser({
    required this.userId,
    required this.role,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      userId: json['userId'] as int,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
    };
  }
}

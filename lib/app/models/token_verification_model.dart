// token 验证响应模型
class TokenVerificationResponse {
  final bool valid;
  final String? role;
  final int? userId;
  final String? username;

  TokenVerificationResponse({
    required this.valid,
    this.role,
    this.userId,
    this.username,
  });

  factory TokenVerificationResponse.fromJson(Map<String, dynamic> json) {
    return TokenVerificationResponse(
      valid: json['valid'] ?? false,
      role: json['role'],
      userId: json['userId'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'role': role,
      'userId': userId,
      'username': username,
    };
  }
}

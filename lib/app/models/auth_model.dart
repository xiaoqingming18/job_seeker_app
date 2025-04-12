/// 认证模型，用于处理登录响应中的令牌
class AuthModel {
  /// 认证令牌
  final String token;

  /// 构造函数
  AuthModel({
    required this.token,
  });

  /// 从 JSON 对象创建 AuthModel 实例
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String,
    );
  }

  /// 将 AuthModel 实例转换为 JSON 对象
  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

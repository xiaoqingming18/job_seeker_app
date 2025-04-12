/// API 响应模型，用于解析所有 API 响应的标准格式
class ApiResponse<T> {
  /// 响应码，0 表示成功
  final int code;
  
  /// 响应数据，可能为 null
  final T? data;
  
  /// 响应消息
  final String message;

  /// 构造函数
  ApiResponse({
    required this.code,
    this.data,
    required this.message,
  });

  /// 从 JSON 对象创建 ApiResponse 实例
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }

  /// 将 ApiResponse 实例转换为 JSON 对象
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'code': code,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    };
  }

  /// 判断响应是否成功
  bool get isSuccess => code == 0;
}

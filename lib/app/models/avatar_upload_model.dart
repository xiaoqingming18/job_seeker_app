/// 头像上传响应模型
class AvatarUploadModel {
  /// 头像URL
  final String url;
  
  /// 对象存储中的对象名称
  final String objectName;

  /// 构造函数
  AvatarUploadModel({
    required this.url,
    required this.objectName,
  });

  /// 从JSON对象创建AvatarUploadModel实例
  factory AvatarUploadModel.fromJson(Map<String, dynamic> json) {
    return AvatarUploadModel(
      url: json['url'] as String,
      objectName: json['objectName'] as String,
    );
  }

  /// 将AvatarUploadModel实例转换为JSON对象
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'objectName': objectName,
    };
  }
}
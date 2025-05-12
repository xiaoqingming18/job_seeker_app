/// 用户模型
class UserModel {
  /// 用户ID (可能来自userId或id字段)
  final int? userId;
  
  /// 直接来自服务器的ID字段
  final int? id;
  
  /// 用户名
  final String? username;
  
  /// 手机号码
  final String? mobile;
  
  /// 电子邮箱
  final String? email;
  
  /// 头像URL
  final String? avatar;
  
  /// 角色（job_seeker：求职者，admin：管理员，company_admin：企业管理员，project_manager：项目经理）
  final String? role;
  
  /// 账号状态
  final String? accountStatus;
  
  /// 创建时间
  final String? createTime;
  
  /// 真实姓名
  final String? realName;
  
  /// 性别
  final String? gender;
  
  /// 出生日期
  final String? birthday;
  
  /// 求职状态
  final String? jobStatus;
  
  /// 期望职位
  final String? expectPosition;
  
  /// 工作年限
  final int? workYears;
  
  /// 专业技能
  final String? skill;
  
  /// 专业证书
  final String? certificates;
  
  /// 简历URL
  final String? resumeUrl;

  /// 构造函数
  UserModel({
    this.userId,
    this.id,
    this.username,
    this.mobile,
    this.email,
    this.avatar,
    this.role,
    this.accountStatus,
    this.createTime,
    this.realName,
    this.gender,
    this.birthday,
    this.jobStatus,
    this.expectPosition,
    this.workYears,
    this.skill,
    this.certificates,
    this.resumeUrl,
  });

  /// 从 JSON 对象创建 UserModel 实例
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 优先使用userId字段，如果不存在则尝试使用id字段
    int? userId = json['userId'] as int?;
    int? id = json['id'] as int?;
    
    return UserModel(
      userId: userId ?? id, // 优先使用userId字段，如果为空则用id字段的值
      id: id,
      username: json['username'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
      accountStatus: json['accountStatus'] as String?,
      createTime: json['createTime'] as String?,
      realName: json['realName'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      jobStatus: json['jobStatus'] as String?,
      expectPosition: json['expectPosition'] as String?,
      workYears: json['workYears'] as int?,
      skill: json['skill'] as String?,
      certificates: json['certificates'] as String?,
      resumeUrl: json['resumeUrl'] as String?,
    );
  }

  /// 将 UserModel 实例转换为 JSON 对象
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userId != null) data['userId'] = userId;
    if (id != null) data['id'] = id;
    if (username != null) data['username'] = username;
    if (mobile != null) data['mobile'] = mobile;
    if (email != null) data['email'] = email;
    if (avatar != null) data['avatar'] = avatar;
    if (role != null) data['role'] = role;
    if (accountStatus != null) data['accountStatus'] = accountStatus;
    if (createTime != null) data['createTime'] = createTime;
    if (realName != null) data['realName'] = realName;
    if (gender != null) data['gender'] = gender;
    if (birthday != null) data['birthday'] = birthday;
    if (jobStatus != null) data['jobStatus'] = jobStatus;
    if (expectPosition != null) data['expectPosition'] = expectPosition;
    if (workYears != null) data['workYears'] = workYears;
    if (skill != null) data['skill'] = skill;
    if (certificates != null) data['certificates'] = certificates;
    if (resumeUrl != null) data['resumeUrl'] = resumeUrl;
    return data;
  }
}

/// Token 验证响应模型
class TokenVerificationResponse {
  /// 是否有效
  final bool valid;
  
  /// 用户ID
  final int userId;
  
  /// 用户名
  final String username;
  
  /// 用户角色
  final String role;

  /// 构造函数
  TokenVerificationResponse({
    required this.valid,
    required this.userId,
    required this.username,
    required this.role,
  });

  /// 从 JSON 对象创建实例
  factory TokenVerificationResponse.fromJson(Map<String, dynamic> json) {
    return TokenVerificationResponse(
      valid: json['valid'] as bool,
      userId: json['userId'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }

  /// 将实例转换为 JSON 对象
  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'userId': userId,
      'username': username,
      'role': role,
    };
  }
}

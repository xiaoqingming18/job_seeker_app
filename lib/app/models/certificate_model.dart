import 'package:json_annotation/json_annotation.dart';

part 'certificate_model.g.dart';

/// 证书状态枚举
enum CertificateStatus {
  @JsonValue('pending')
  pending, // 待审核
  @JsonValue('verified')
  verified, // 已通过
  @JsonValue('rejected')
  rejected, // 已拒绝
}

/// 证书信息模型
@JsonSerializable()
class Certificate {
  final int? id; // 证书ID
  final int? jobSeekerId; // 求职者ID
  final String? jobSeekerName; // 求职者姓名
  final String certificateName; // 证书名称
  final String? certificateNo; // 证书编号
  final int? certificateTypeId; // 证书类型ID
  final String? certificateTypeName; // 证书类型名称
  final String? issuingAuthority; // 发证机构
  final DateTime? issueDate; // 发证日期
  final DateTime? expiryDate; // 有效期至
  final String? imageUrl; // 证书图片URL
  @JsonKey(name: 'verificationStatus')
  final CertificateStatus status; // 审核状态
  final String? verificationComment; // 审核备注
  final DateTime? createTime; // 创建时间
  final DateTime? updateTime; // 更新时间

  Certificate({
    this.id,
    this.jobSeekerId,
    this.jobSeekerName,
    required this.certificateName,
    this.certificateNo,
    this.certificateTypeId,
    this.certificateTypeName,
    this.issuingAuthority,
    this.issueDate,
    this.expiryDate,
    this.imageUrl,
    this.status = CertificateStatus.pending,
    this.verificationComment,
    this.createTime,
    this.updateTime,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) => 
      _$CertificateFromJson(json);
  
  Map<String, dynamic> toJson() => _$CertificateToJson(this);

  // 状态显示文本
  String get statusText {
    switch (status) {
      case CertificateStatus.pending:
        return '待审核';
      case CertificateStatus.verified:
        return '已通过';
      case CertificateStatus.rejected:
        return '已拒绝';
    }
  }
  
  // 状态对应的颜色
  String get statusColor {
    switch (status) {
      case CertificateStatus.pending:
        return '#FF9800'; // 橙色
      case CertificateStatus.verified:
        return '#4CAF50'; // 绿色
      case CertificateStatus.rejected:
        return '#F44336'; // 红色
    }
  }
  
  // 返回完整的图片URL，处理可能不完整的URL
  String get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return '';
    }
    
    // 如果已经是完整URL，直接返回
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl!;
    }
    
    // 使用MinIO服务器的地址
    const String minioServerUrl = 'http://192.168.200.60:9000';
    const String minioBucket = 'job-server';
    
    // 修正URL格式
    String formattedUrl = imageUrl!;
    if (!formattedUrl.startsWith('/')) {
      formattedUrl = '/$formattedUrl';
    }
    
    // 构建完整URL
    return '$minioServerUrl/$minioBucket$formattedUrl';
  }
}

/// 证书类型模型
@JsonSerializable()
class CertificateType {
  final int? id; // 类型ID
  final String name; // 类型名称
  final String? category; // 证书类别
  final String? issuingAuthority; // 发证机构
  final int? validityYears; // 有效期(年)
  final String? icon; // 图标URL
  final String? description; // 描述
  final int status; // 状态：1-启用，0-禁用
  final DateTime? createTime; // 创建时间
  final DateTime? updateTime; // 更新时间

  CertificateType({
    this.id,
    required this.name,
    this.category,
    this.issuingAuthority,
    this.validityYears,
    this.icon,
    this.description,
    this.status = 1,
    this.createTime,
    this.updateTime,
  });

  factory CertificateType.fromJson(Map<String, dynamic> json) => 
      _$CertificateTypeFromJson(json);
  
  Map<String, dynamic> toJson() => _$CertificateTypeToJson(this);
}

/// 证书列表响应模型
@JsonSerializable()
class CertificateListResponse {
  final List<Certificate> records;
  final int total;
  final int size;
  final int current;

  CertificateListResponse({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
  });

  factory CertificateListResponse.fromJson(Map<String, dynamic> json) => 
      _$CertificateListResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$CertificateListResponseToJson(this);
}

/// 证书类型列表响应模型
@JsonSerializable()
class CertificateTypeListResponse {
  final List<CertificateType> records;
  final int total;
  final int size;
  final int current;

  CertificateTypeListResponse({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
  });

  factory CertificateTypeListResponse.fromJson(Map<String, dynamic> json) => 
      _$CertificateTypeListResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$CertificateTypeListResponseToJson(this);
} 
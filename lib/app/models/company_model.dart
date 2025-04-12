/// 企业模型
class CompanyModel {
  /// 企业ID
  final int? id;
  
  /// 企业名称
  final String? name;
  
  /// 营业执照号
  final String? licenseNumber;
  
  /// 企业地址
  final String? address;
  
  /// 法定代表人
  final String? legalPerson;
  
  /// 创建时间
  final String? createTime;

  /// 构造函数
  CompanyModel({
    this.id,
    this.name,
    this.licenseNumber,
    this.address,
    this.legalPerson,
    this.createTime,
  });

  /// 从JSON对象创建CompanyModel实例
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      address: json['address'] as String?,
      legalPerson: json['legalPerson'] as String?,
      createTime: json['createTime'] as String?,
    );
  }

  /// 将CompanyModel实例转换为JSON对象
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (licenseNumber != null) data['licenseNumber'] = licenseNumber;
    if (address != null) data['address'] = address;
    if (legalPerson != null) data['legalPerson'] = legalPerson;
    if (createTime != null) data['createTime'] = createTime;
    return data;
  }
}

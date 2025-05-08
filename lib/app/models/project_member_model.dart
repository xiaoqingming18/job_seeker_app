/// 项目成员模型
class ProjectMemberModel {
  /// 记录ID
  final int? id;
  
  /// 项目ID
  final int? projectId;
  
  /// 项目名称
  final String? projectName;
  
  /// 用户ID
  final int? userId;
  
  /// 用户名
  final String? username;
  
  /// 手机号码
  final String? mobile;
  
  /// 工种ID
  final int? jobTypeId;
  
  /// 工种名称
  final String? jobTypeName;
  
  /// 职位名称
  final String? position;
  
  /// 日薪
  final double? dailyWage;
  
  /// 入场日期
  final String? joinDate;
  
  /// 计划离场日期
  final String? plannedEndDate;
  
  /// 实际离场日期
  final String? actualEndDate;
  
  /// 状态
  final String? status;
  
  /// 状态描述
  final String? statusDesc;
  
  /// 考勤编号
  final String? attendanceCode;
  
  /// 紧急联系人
  final String? emergencyContact;
  
  /// 紧急联系电话
  final String? emergencyPhone;
  
  /// 备注
  final String? remarks;
  
  /// 合同ID
  final int? contractId;
  
  /// 创建时间
  final String? createTime;
  
  /// 更新时间
  final String? updateTime;

  /// 构造函数
  ProjectMemberModel({
    this.id,
    this.projectId,
    this.projectName,
    this.userId,
    this.username,
    this.mobile,
    this.jobTypeId,
    this.jobTypeName,
    this.position,
    this.dailyWage,
    this.joinDate,
    this.plannedEndDate,
    this.actualEndDate,
    this.status,
    this.statusDesc,
    this.attendanceCode,
    this.emergencyContact,
    this.emergencyPhone,
    this.remarks,
    this.contractId,
    this.createTime,
    this.updateTime,
  });

  /// 从JSON对象创建实例
  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'] as int?,
      projectId: json['projectId'] as int?,
      projectName: json['projectName'] as String?,
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      mobile: json['mobile'] as String?,
      jobTypeId: json['jobTypeId'] as int?,
      jobTypeName: json['jobTypeName'] as String?,
      position: json['position'] as String?,
      dailyWage: json['dailyWage'] is int ? (json['dailyWage'] as int).toDouble() : json['dailyWage'] as double?,
      joinDate: json['joinDate'] as String?,
      plannedEndDate: json['plannedEndDate'] as String?,
      actualEndDate: json['actualEndDate'] as String?,
      status: json['status'] as String?,
      statusDesc: json['statusDesc'] as String?,
      attendanceCode: json['attendanceCode'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      remarks: json['remarks'] as String?,
      contractId: json['contractId'] as int?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );
  }

  /// 将实例转换为JSON对象
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (projectId != null) data['projectId'] = projectId;
    if (projectName != null) data['projectName'] = projectName;
    if (userId != null) data['userId'] = userId;
    if (username != null) data['username'] = username;
    if (mobile != null) data['mobile'] = mobile;
    if (jobTypeId != null) data['jobTypeId'] = jobTypeId;
    if (jobTypeName != null) data['jobTypeName'] = jobTypeName;
    if (position != null) data['position'] = position;
    if (dailyWage != null) data['dailyWage'] = dailyWage;
    if (joinDate != null) data['joinDate'] = joinDate;
    if (plannedEndDate != null) data['plannedEndDate'] = plannedEndDate;
    if (actualEndDate != null) data['actualEndDate'] = actualEndDate;
    if (status != null) data['status'] = status;
    if (statusDesc != null) data['statusDesc'] = statusDesc;
    if (attendanceCode != null) data['attendanceCode'] = attendanceCode;
    if (emergencyContact != null) data['emergencyContact'] = emergencyContact;
    if (emergencyPhone != null) data['emergencyPhone'] = emergencyPhone;
    if (remarks != null) data['remarks'] = remarks;
    if (contractId != null) data['contractId'] = contractId;
    if (createTime != null) data['createTime'] = createTime;
    if (updateTime != null) data['updateTime'] = updateTime;
    return data;
  }
} 
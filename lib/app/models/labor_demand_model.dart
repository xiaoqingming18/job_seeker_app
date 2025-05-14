import 'package:json_annotation/json_annotation.dart';

part 'labor_demand_model.g.dart';

/// 劳务需求数据模型
@JsonSerializable()
class LaborDemandModel {
  final int id;
  final String title;
  final int projectId;
  final String projectName;
  final String? projectAddress;
  final int jobTypeId;
  final String jobTypeName;
  final String? jobTypeCategory;
  final int headcount;
  final double dailyWage;
  final String startDate;
  final String endDate;
  final String? workHours;
  final String? requirements;
  final bool accommodation;
  final bool meals;
  final String status;
  final String? createTime;
  final String? updateTime;
  final String companyName;
  final int? projectManagerId; // 项目经理ID，用于沟通功能

  LaborDemandModel({
    required this.id,
    required this.title,
    required this.projectId,
    required this.projectName,
    this.projectAddress,
    required this.jobTypeId,
    required this.jobTypeName,
    this.jobTypeCategory,
    required this.headcount,
    required this.dailyWage,
    required this.startDate,
    required this.endDate,
    this.workHours,
    this.requirements,
    required this.accommodation,
    required this.meals,
    required this.status,
    this.createTime,
    this.updateTime,
    required this.companyName,
    this.projectManagerId,
  });

  /// 从JSON映射到对象
  factory LaborDemandModel.fromJson(Map<String, dynamic> json) => _$LaborDemandModelFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$LaborDemandModelToJson(this);
}

/// 劳务需求分页响应模型
@JsonSerializable()
class LaborDemandPageModel {
  final List<LaborDemandModel> records;
  final int total;
  final int size;
  final int current;
  final int pages;

  LaborDemandPageModel({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.pages,
  });

  /// 从JSON映射到对象
  factory LaborDemandPageModel.fromJson(Map<String, dynamic> json) => _$LaborDemandPageModelFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$LaborDemandPageModelToJson(this);
}

/// 劳务需求查询条件
@JsonSerializable()
class LaborDemandQuery {
  final int pageNum;
  final int pageSize;
  final int? companyId;
  final int? projectId;
  final int? jobTypeId;
  final double? minDailyWage;
  final double? maxDailyWage;
  final String? startDate;
  final String? endDate;
  final bool? accommodation;
  final bool? meals;
  final String? status;
  final String? projectType;
  final int? categoryId;
  final int? occupationId;

  LaborDemandQuery({
    this.pageNum = 1,
    this.pageSize = 10,
    this.companyId,
    this.projectId,
    this.jobTypeId,
    this.minDailyWage,
    this.maxDailyWage,
    this.startDate,
    this.endDate,
    this.accommodation,
    this.meals,
    this.status,
    this.projectType,
    this.categoryId,
    this.occupationId,
  });

  /// 从JSON映射到对象
  factory LaborDemandQuery.fromJson(Map<String, dynamic> json) => _$LaborDemandQueryFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$LaborDemandQueryToJson(this);
} 
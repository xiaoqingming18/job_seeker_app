// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labor_demand_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaborDemandModel _$LaborDemandModelFromJson(Map<String, dynamic> json) =>
    LaborDemandModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      projectId: (json['projectId'] as num).toInt(),
      projectName: json['projectName'] as String,
      projectAddress: json['projectAddress'] as String?,
      jobTypeId: (json['jobTypeId'] as num).toInt(),
      jobTypeName: json['jobTypeName'] as String,
      jobTypeCategory: json['jobTypeCategory'] as String?,
      headcount: (json['headcount'] as num).toInt(),
      dailyWage: (json['dailyWage'] as num).toDouble(),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      workHours: json['workHours'] as String?,
      requirements: json['requirements'] as String?,
      accommodation: json['accommodation'] as bool,
      meals: json['meals'] as bool,
      status: json['status'] as String,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      companyName: json['companyName'] as String,
      projectManagerId: json['projectManagerId'] == null
          ? null
          : (json['projectManagerId'] as num).toInt(),
    );

Map<String, dynamic> _$LaborDemandModelToJson(LaborDemandModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'projectId': instance.projectId,
      'projectName': instance.projectName,
      'projectAddress': instance.projectAddress,
      'jobTypeId': instance.jobTypeId,
      'jobTypeName': instance.jobTypeName,
      'jobTypeCategory': instance.jobTypeCategory,
      'headcount': instance.headcount,
      'dailyWage': instance.dailyWage,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'workHours': instance.workHours,
      'requirements': instance.requirements,
      'accommodation': instance.accommodation,
      'meals': instance.meals,
      'status': instance.status,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'companyName': instance.companyName,
      'projectManagerId': instance.projectManagerId,
    };

LaborDemandPageModel _$LaborDemandPageModelFromJson(
        Map<String, dynamic> json) =>
    LaborDemandPageModel(
      records: (json['records'] as List<dynamic>)
          .map((e) => LaborDemandModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      current: (json['current'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
    );

Map<String, dynamic> _$LaborDemandPageModelToJson(
        LaborDemandPageModel instance) =>
    <String, dynamic>{
      'records': instance.records,
      'total': instance.total,
      'size': instance.size,
      'current': instance.current,
      'pages': instance.pages,
    };

LaborDemandQuery _$LaborDemandQueryFromJson(Map<String, dynamic> json) =>
    LaborDemandQuery(
      pageNum: (json['pageNum'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      companyId: (json['companyId'] as num?)?.toInt(),
      projectId: (json['projectId'] as num?)?.toInt(),
      jobTypeId: (json['jobTypeId'] as num?)?.toInt(),
      minDailyWage: (json['minDailyWage'] as num?)?.toDouble(),
      maxDailyWage: (json['maxDailyWage'] as num?)?.toDouble(),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      accommodation: json['accommodation'] as bool?,
      meals: json['meals'] as bool?,
      status: json['status'] as String?,
      projectType: json['projectType'] as String?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      occupationId: (json['occupationId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LaborDemandQueryToJson(LaborDemandQuery instance) =>
    <String, dynamic>{
      'pageNum': instance.pageNum,
      'pageSize': instance.pageSize,
      'companyId': instance.companyId,
      'projectId': instance.projectId,
      'jobTypeId': instance.jobTypeId,
      'minDailyWage': instance.minDailyWage,
      'maxDailyWage': instance.maxDailyWage,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'accommodation': instance.accommodation,
      'meals': instance.meals,
      'status': instance.status,
      'projectType': instance.projectType,
      'categoryId': instance.categoryId,
      'occupationId': instance.occupationId,
    };

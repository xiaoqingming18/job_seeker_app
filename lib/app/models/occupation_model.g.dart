// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occupation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OccupationModel _$OccupationModelFromJson(Map<String, dynamic> json) =>
    OccupationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryId: json['categoryId'] as int,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      requiredCertificates: (json['requiredCertificates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      averageDailyWage: (json['averageDailyWage'] as num).toDouble(),
      difficultyLevel: json['difficultyLevel'] as int,
      status: json['status'] as int,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      categoryName: json['categoryName'] as String?,
    );

Map<String, dynamic> _$OccupationModelToJson(OccupationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'icon': instance.icon,
      'description': instance.description,
      'requiredCertificates': instance.requiredCertificates,
      'averageDailyWage': instance.averageDailyWage,
      'difficultyLevel': instance.difficultyLevel,
      'status': instance.status,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'categoryName': instance.categoryName,
    };

HotOccupationsResponse _$HotOccupationsResponseFromJson(
        Map<String, dynamic> json) =>
    HotOccupationsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => OccupationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HotOccupationsResponseToJson(
        HotOccupationsResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    }; 
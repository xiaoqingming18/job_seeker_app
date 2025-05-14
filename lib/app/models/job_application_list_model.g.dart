// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationListModel _$JobApplicationListModelFromJson(
        Map<String, dynamic> json) =>
    JobApplicationListModel(
      list: (json['list'] as List<dynamic>)
          .map((e) => JobApplicationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      pageNum: (json['pageNum'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$JobApplicationListModelToJson(
        JobApplicationListModel instance) =>
    <String, dynamic>{
      'list': instance.list,
      'total': instance.total,
      'pageNum': instance.pageNum,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };

JobApplicationItem _$JobApplicationItemFromJson(Map<String, dynamic> json) =>
    JobApplicationItem(
      id: (json['id'] as num).toInt(),
      jobSeekerId: (json['jobSeekerId'] as num).toInt(),
      jobSeekerName: json['jobSeekerName'] as String,
      demandId: (json['demandId'] as num).toInt(),
      demandTitle: json['demandTitle'] as String,
      expectedEntryDate: json['expectedEntryDate'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      status: json['status'] as String,
      createTime: json['createTime'] as String,
    );

Map<String, dynamic> _$JobApplicationItemToJson(JobApplicationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobSeekerId': instance.jobSeekerId,
      'jobSeekerName': instance.jobSeekerName,
      'demandId': instance.demandId,
      'demandTitle': instance.demandTitle,
      'expectedEntryDate': instance.expectedEntryDate,
      'expectedSalary': instance.expectedSalary,
      'status': instance.status,
      'createTime': instance.createTime,
    };

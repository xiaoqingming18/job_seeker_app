// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationListModel _$JobApplicationListModelFromJson(Map<String, dynamic> json) =>
    JobApplicationListModel(
      list: (json['list'] as List<dynamic>)
          .map((e) => JobApplicationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      pageNum: json['pageNum'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );

Map<String, dynamic> _$JobApplicationListModelToJson(JobApplicationListModel instance) =>
    <String, dynamic>{
      'list': instance.list,
      'total': instance.total,
      'pageNum': instance.pageNum,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };

JobApplicationItem _$JobApplicationItemFromJson(Map<String, dynamic> json) =>
    JobApplicationItem(
      id: json['id'] as int,
      jobSeekerId: json['jobSeekerId'] as int,
      jobSeekerName: json['jobSeekerName'] as String,
      demandId: json['demandId'] as int,
      demandTitle: json['demandTitle'] as String,
      expectedEntryDate: json['expectedEntryDate'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      status: json['status'] as String,
      createTime: json['createTime'] as String,
    );

Map<String, dynamic> _$JobApplicationItemToJson(JobApplicationItem instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'jobSeekerId': instance.jobSeekerId,
    'jobSeekerName': instance.jobSeekerName,
    'demandId': instance.demandId,
    'demandTitle': instance.demandTitle,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('expectedEntryDate', instance.expectedEntryDate);
  writeNotNull('expectedSalary', instance.expectedSalary);
  val['status'] = instance.status;
  val['createTime'] = instance.createTime;
  return val;
} 
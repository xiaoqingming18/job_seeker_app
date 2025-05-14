// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationRequest _$JobApplicationRequestFromJson(
        Map<String, dynamic> json) =>
    JobApplicationRequest(
      demandId: (json['demandId'] as num).toInt(),
      selfIntroduction: json['selfIntroduction'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      expectedStartDate: json['expectedStartDate'] as String?,
    );

Map<String, dynamic> _$JobApplicationRequestToJson(
        JobApplicationRequest instance) =>
    <String, dynamic>{
      'demandId': instance.demandId,
      'selfIntroduction': instance.selfIntroduction,
      'expectedSalary': instance.expectedSalary,
      'expectedStartDate': instance.expectedStartDate,
    };

JobApplicationResponse _$JobApplicationResponseFromJson(
        Map<String, dynamic> json) =>
    JobApplicationResponse(
      id: (json['id'] as num?)?.toInt(),
      jobSeekerId: (json['jobSeekerId'] as num?)?.toInt(),
      jobSeekerName: json['jobSeekerName'] as String?,
      jobSeekerGender: json['jobSeekerGender'] as String?,
      jobSeekerAge: (json['jobSeekerAge'] as num?)?.toInt(),
      jobSeekerWorkYears: (json['jobSeekerWorkYears'] as num?)?.toInt(),
      jobSeekerSkill: json['jobSeekerSkill'] as String?,
      resumeUrl: json['resumeUrl'] as String?,
      demandId: (json['demandId'] as num?)?.toInt(),
      demandTitle: json['demandTitle'] as String?,
      projectId: (json['projectId'] as num?)?.toInt(),
      projectName: json['projectName'] as String?,
      selfIntroduction: json['selfIntroduction'] as String?,
      expectedEntryDate: json['expectedEntryDate'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      status: json['status'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createTime: json['createTime'] as String?,
      interviews: json['interviews'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$JobApplicationResponseToJson(
        JobApplicationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobSeekerId': instance.jobSeekerId,
      'jobSeekerName': instance.jobSeekerName,
      'jobSeekerGender': instance.jobSeekerGender,
      'jobSeekerAge': instance.jobSeekerAge,
      'jobSeekerWorkYears': instance.jobSeekerWorkYears,
      'jobSeekerSkill': instance.jobSeekerSkill,
      'resumeUrl': instance.resumeUrl,
      'demandId': instance.demandId,
      'demandTitle': instance.demandTitle,
      'projectId': instance.projectId,
      'projectName': instance.projectName,
      'selfIntroduction': instance.selfIntroduction,
      'expectedEntryDate': instance.expectedEntryDate,
      'expectedSalary': instance.expectedSalary,
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'createTime': instance.createTime,
      'interviews': instance.interviews,
    };

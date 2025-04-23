// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationRequest _$JobApplicationRequestFromJson(Map<String, dynamic> json) =>
    JobApplicationRequest(
      demandId: json['demandId'] as int,
      selfIntroduction: json['selfIntroduction'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      expectedStartDate: json['expectedStartDate'] as String?,
    );

Map<String, dynamic> _$JobApplicationRequestToJson(JobApplicationRequest instance) {
  final val = <String, dynamic>{
    'demandId': instance.demandId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('selfIntroduction', instance.selfIntroduction);
  writeNotNull('expectedSalary', instance.expectedSalary);
  writeNotNull('expectedStartDate', instance.expectedStartDate);
  return val;
}

JobApplicationResponse _$JobApplicationResponseFromJson(
        Map<String, dynamic> json) =>
    JobApplicationResponse(
      id: json['id'] as int?,
      jobSeekerId: json['jobSeekerId'] as int?,
      jobSeekerName: json['jobSeekerName'] as String?,
      jobSeekerGender: json['jobSeekerGender'] as String?,
      jobSeekerAge: json['jobSeekerAge'] as int?,
      jobSeekerWorkYears: json['jobSeekerWorkYears'] as int?,
      jobSeekerSkill: json['jobSeekerSkill'] as String?,
      resumeUrl: json['resumeUrl'] as String?,
      demandId: json['demandId'] as int?,
      demandTitle: json['demandTitle'] as String?,
      projectId: json['projectId'] as int?,
      projectName: json['projectName'] as String?,
      selfIntroduction: json['selfIntroduction'] as String?,
      expectedEntryDate: json['expectedEntryDate'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      status: json['status'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createTime: json['createTime'] as String?,
      interviews: json['interviews'] as List<dynamic>?,
    );

Map<String, dynamic> _$JobApplicationResponseToJson(
        JobApplicationResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('jobSeekerId', instance.jobSeekerId);
  writeNotNull('jobSeekerName', instance.jobSeekerName);
  writeNotNull('jobSeekerGender', instance.jobSeekerGender);
  writeNotNull('jobSeekerAge', instance.jobSeekerAge);
  writeNotNull('jobSeekerWorkYears', instance.jobSeekerWorkYears);
  writeNotNull('jobSeekerSkill', instance.jobSeekerSkill);
  writeNotNull('resumeUrl', instance.resumeUrl);
  writeNotNull('demandId', instance.demandId);
  writeNotNull('demandTitle', instance.demandTitle);
  writeNotNull('projectId', instance.projectId);
  writeNotNull('projectName', instance.projectName);
  writeNotNull('selfIntroduction', instance.selfIntroduction);
  writeNotNull('expectedEntryDate', instance.expectedEntryDate);
  writeNotNull('expectedSalary', instance.expectedSalary);
  writeNotNull('status', instance.status);
  writeNotNull('rejectionReason', instance.rejectionReason);
  writeNotNull('createTime', instance.createTime);
  writeNotNull('interviews', instance.interviews);
  return val;
} 
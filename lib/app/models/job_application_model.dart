import 'package:json_annotation/json_annotation.dart';

part 'job_application_model.g.dart';

/// 求职申请请求模型
@JsonSerializable()
class JobApplicationRequest {
  final int demandId;
  final String? selfIntroduction;
  final double? expectedSalary;
  final String? expectedStartDate;

  JobApplicationRequest({
    required this.demandId,
    this.selfIntroduction,
    this.expectedSalary,
    this.expectedStartDate,
  });

  /// 从JSON映射到对象
  factory JobApplicationRequest.fromJson(Map<String, dynamic> json) => 
      _$JobApplicationRequestFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$JobApplicationRequestToJson(this);
}

/// 求职申请响应模型
@JsonSerializable()
class JobApplicationResponse {
  final int? id;
  final int? jobSeekerId;
  final String? jobSeekerName;
  final String? jobSeekerGender;
  final int? jobSeekerAge;
  final int? jobSeekerWorkYears;
  final String? jobSeekerSkill;
  final String? resumeUrl;
  final int? demandId;
  final String? demandTitle;
  final int? projectId;
  final String? projectName;
  final String? selfIntroduction;
  final String? expectedEntryDate;
  final double? expectedSalary;
  final String? status;
  final String? rejectionReason;
  final String? createTime;
  final List<dynamic>? interviews;

  JobApplicationResponse({
    this.id,
    this.jobSeekerId,
    this.jobSeekerName,
    this.jobSeekerGender,
    this.jobSeekerAge,
    this.jobSeekerWorkYears,
    this.jobSeekerSkill,
    this.resumeUrl,
    this.demandId,
    this.demandTitle,
    this.projectId,
    this.projectName,
    this.selfIntroduction,
    this.expectedEntryDate,
    this.expectedSalary,
    this.status,
    this.rejectionReason,
    this.createTime,
    this.interviews = const [],
  });

  /// 从JSON映射到对象
  factory JobApplicationResponse.fromJson(Map<String, dynamic> json) => 
      _$JobApplicationResponseFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$JobApplicationResponseToJson(this);
} 
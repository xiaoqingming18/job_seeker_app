import 'package:json_annotation/json_annotation.dart';

part 'resume_model.g.dart';

/// 简历基本信息DTO
@JsonSerializable()
class ResumeDTO {
  final int? id;
  final int? userId;
  final String? type; // 简历类型：online - 在线简历，attachment - 附件简历
  final String? title; // 简历标题
  final String? status; // 状态：draft - 草稿，published - 已发布
  final bool? isDefault; // 是否默认简历
  final String? createTime;
  final String? updateTime;

  ResumeDTO({
    this.id,
    this.userId,
    this.type,
    this.title,
    this.status,
    this.isDefault,
    this.createTime,
    this.updateTime,
  });

  factory ResumeDTO.fromJson(Map<String, dynamic> json) =>
      _$ResumeDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeDTOToJson(this);
}

/// 在线简历DTO
@JsonSerializable()
class OnlineResumeDTO {
  final int? id;
  final int? resumeId;
  final ResumeDTO? resumeInfo;
  final String? realName;
  final String? gender;
  final String? birthDate;
  final String? phone;
  final String? email;
  final String? highestEducation;
  final int? workYears;
  final String? selfDescription;
  final String? jobIntention;
  final double? expectedSalary;
  final String? expectedCity;
  final String? avatar;
  final String? createTime;
  final String? updateTime;
  final List<WorkExperienceDTO>? workExperiences;
  final List<EducationExperienceDTO>? educationExperiences;
  final List<ProjectExperienceDTO>? projectExperiences;
  final List<ResumeSkillDTO>? skills;

  OnlineResumeDTO({
    this.id,
    this.resumeId,
    this.resumeInfo,
    this.realName,
    this.gender,
    this.birthDate,
    this.phone,
    this.email,
    this.highestEducation,
    this.workYears,
    this.selfDescription,
    this.jobIntention,
    this.expectedSalary,
    this.expectedCity,
    this.avatar,
    this.createTime,
    this.updateTime,
    this.workExperiences,
    this.educationExperiences,
    this.projectExperiences,
    this.skills,
  });

  factory OnlineResumeDTO.fromJson(Map<String, dynamic> json) =>
      _$OnlineResumeDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OnlineResumeDTOToJson(this);
}

/// 附件简历DTO
@JsonSerializable()
class AttachmentResumeDTO {
  final int? id;
  final int? resumeId;
  final ResumeDTO? resumeInfo;
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final String? fileType;
  final String? createTime;
  final String? updateTime;

  AttachmentResumeDTO({
    this.id,
    this.resumeId,
    this.resumeInfo,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.fileType,
    this.createTime,
    this.updateTime,
  });

  factory AttachmentResumeDTO.fromJson(Map<String, dynamic> json) =>
      _$AttachmentResumeDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentResumeDTOToJson(this);
}

/// 工作经历DTO
@JsonSerializable()
class WorkExperienceDTO {
  final int? id;
  final int? resumeId;
  final String? companyName;
  final String? position;
  final String? startDate;
  final String? endDate;
  final String? description;
  final String? createTime;
  final String? updateTime;

  WorkExperienceDTO({
    this.id,
    this.resumeId,
    this.companyName,
    this.position,
    this.startDate,
    this.endDate,
    this.description,
    this.createTime,
    this.updateTime,
  });

  factory WorkExperienceDTO.fromJson(Map<String, dynamic> json) =>
      _$WorkExperienceDTOFromJson(json);

  Map<String, dynamic> toJson() => _$WorkExperienceDTOToJson(this);
}

/// 教育经历DTO
@JsonSerializable()
class EducationExperienceDTO {
  final int? id;
  final int? resumeId;
  final String? schoolName;
  final String? major;
  final String? degree;
  final String? startDate;
  final String? endDate;
  final String? createTime;
  final String? updateTime;

  EducationExperienceDTO({
    this.id,
    this.resumeId,
    this.schoolName,
    this.major,
    this.degree,
    this.startDate,
    this.endDate,
    this.createTime,
    this.updateTime,
  });

  factory EducationExperienceDTO.fromJson(Map<String, dynamic> json) =>
      _$EducationExperienceDTOFromJson(json);

  Map<String, dynamic> toJson() => _$EducationExperienceDTOToJson(this);
}

/// 项目经验DTO
@JsonSerializable()
class ProjectExperienceDTO {
  final int? id;
  final int? resumeId;
  final String? projectName;
  final String? role;
  final String? startDate;
  final String? endDate;
  final String? description;
  final String? createTime;
  final String? updateTime;

  ProjectExperienceDTO({
    this.id,
    this.resumeId,
    this.projectName,
    this.role,
    this.startDate,
    this.endDate,
    this.description,
    this.createTime,
    this.updateTime,
  });

  factory ProjectExperienceDTO.fromJson(Map<String, dynamic> json) =>
      _$ProjectExperienceDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectExperienceDTOToJson(this);
}

/// 简历技能DTO
@JsonSerializable()
class ResumeSkillDTO {
  final int? id;
  final int? resumeId;
  final int? occupationId;
  final String? occupationName;
  final String? proficiency; // 熟练度: beginner - 入门, intermediate - 中级, advanced - 高级, expert - 专家
  final String? createTime;

  ResumeSkillDTO({
    this.id,
    this.resumeId,
    this.occupationId,
    this.occupationName,
    this.proficiency,
    this.createTime,
  });

  factory ResumeSkillDTO.fromJson(Map<String, dynamic> json) =>
      _$ResumeSkillDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeSkillDTOToJson(this);
}

/// 创建简历参数DTO
class ResumeCreateDTO {
  final String? type;
  final String title;
  final String status;
  final bool? isDefault;

  ResumeCreateDTO({
    this.type,
    required this.title,
    required this.status,
    this.isDefault,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'status': status,
        'isDefault': isDefault,
      };
}

/// 更新简历信息参数DTO
class ResumeUpdateDTO {
  final int id;
  final String? title;
  final String? status;
  final bool? isDefault;

  ResumeUpdateDTO({
    required this.id,
    this.title,
    this.status,
    this.isDefault,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'isDefault': isDefault,
      };
}

/// 在线简历创建DTO
@JsonSerializable()
class OnlineResumeCreateDTO {
  @JsonKey(
    fromJson: _resumeCreateDTOFromJson,
    toJson: _resumeCreateDTOToJson,
  )
  final ResumeCreateDTO resumeInfo;
  final String realName;
  final String? gender;
  final String? birthDate;
  final String phone;
  final String? email;
  final String? highestEducation;
  final int? workYears;
  final String? selfDescription;
  final String? jobIntention;
  final double? expectedSalary;
  final String? expectedCity;
  final String? avatar;
  @JsonKey(
    fromJson: _workExperiencesFromJson,
    toJson: _workExperiencesToJson,
  )
  final List<WorkExperienceDTO>? workExperiences;
  @JsonKey(
    fromJson: _educationExperiencesFromJson,
    toJson: _educationExperiencesToJson,
  )
  final List<EducationExperienceDTO>? educationExperiences;
  @JsonKey(
    fromJson: _projectExperiencesFromJson,
    toJson: _projectExperiencesToJson,
  )
  final List<ProjectExperienceDTO>? projectExperiences;
  @JsonKey(
    fromJson: _skillsFromJson,
    toJson: _skillsToJson,
  )
  final List<ResumeSkillDTO>? skills;

  OnlineResumeCreateDTO({
    required this.resumeInfo,
    required this.realName,
    this.gender,
    this.birthDate,
    required this.phone,
    this.email,
    this.highestEducation,
    this.workYears,
    this.selfDescription,
    this.jobIntention,
    this.expectedSalary,
    this.expectedCity,
    this.avatar,
    this.workExperiences,
    this.educationExperiences,
    this.projectExperiences,
    this.skills,
  });

  factory OnlineResumeCreateDTO.fromJson(Map<String, dynamic> json) =>
      _$OnlineResumeCreateDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OnlineResumeCreateDTOToJson(this);
}

/// 附件简历创建DTO
@JsonSerializable()
class AttachmentResumeCreateDTO {
  @JsonKey(
    fromJson: _resumeCreateDTOFromJson,
    toJson: _resumeCreateDTOToJson,
  )
  final ResumeCreateDTO resumeInfo;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String fileType;

  AttachmentResumeCreateDTO({
    required this.resumeInfo,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.fileType,
  });

  factory AttachmentResumeCreateDTO.fromJson(Map<String, dynamic> json) =>
      _$AttachmentResumeCreateDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentResumeCreateDTOToJson(this);
}

/// 在线简历更新DTO
@JsonSerializable()
class OnlineResumeUpdateDTO {
  final int id;
  @JsonKey(
    fromJson: _resumeUpdateDTOFromJson,
    toJson: _resumeUpdateDTOToJson,
  )
  final ResumeUpdateDTO resumeInfo;
  final String? realName;
  final String? gender;
  final String? birthDate;
  final String? phone;
  final String? email;
  final String? highestEducation;
  final int? workYears;
  final String? selfDescription;
  final String? jobIntention;
  final double? expectedSalary;
  final String? expectedCity;
  final String? avatar;
  @JsonKey(
    fromJson: _workExperiencesFromJson,
    toJson: _workExperiencesToJson,
  )
  final List<WorkExperienceDTO>? workExperiences;
  @JsonKey(
    fromJson: _educationExperiencesFromJson,
    toJson: _educationExperiencesToJson,
  )
  final List<EducationExperienceDTO>? educationExperiences;
  @JsonKey(
    fromJson: _projectExperiencesFromJson,
    toJson: _projectExperiencesToJson,
  )
  final List<ProjectExperienceDTO>? projectExperiences;
  @JsonKey(
    fromJson: _skillsFromJson,
    toJson: _skillsToJson,
  )
  final List<ResumeSkillDTO>? skills;

  OnlineResumeUpdateDTO({
    required this.id,
    required this.resumeInfo,
    this.realName,
    this.gender,
    this.birthDate,
    this.phone,
    this.email,
    this.highestEducation,
    this.workYears,
    this.selfDescription,
    this.jobIntention,
    this.expectedSalary,
    this.expectedCity,
    this.avatar,
    this.workExperiences,
    this.educationExperiences,
    this.projectExperiences,
    this.skills,
  });

  factory OnlineResumeUpdateDTO.fromJson(Map<String, dynamic> json) =>
      _$OnlineResumeUpdateDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OnlineResumeUpdateDTOToJson(this);
}

// Helper functions for JSON conversion
ResumeCreateDTO _resumeCreateDTOFromJson(Map<String, dynamic> json) => 
    ResumeCreateDTO(
      type: json['type'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _resumeCreateDTOToJson(ResumeCreateDTO instance) => instance.toJson();

ResumeUpdateDTO _resumeUpdateDTOFromJson(Map<String, dynamic> json) => 
    ResumeUpdateDTO(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      status: json['status'] as String?,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _resumeUpdateDTOToJson(ResumeUpdateDTO instance) => instance.toJson();

List<WorkExperienceDTO>? _workExperiencesFromJson(List<dynamic>? json) => 
    json?.map((e) => WorkExperienceDTO.fromJson(e as Map<String, dynamic>)).toList();

List<dynamic>? _workExperiencesToJson(List<WorkExperienceDTO>? instance) => 
    instance?.map((e) => e.toJson()).toList();

List<EducationExperienceDTO>? _educationExperiencesFromJson(List<dynamic>? json) => 
    json?.map((e) => EducationExperienceDTO.fromJson(e as Map<String, dynamic>)).toList();

List<dynamic>? _educationExperiencesToJson(List<EducationExperienceDTO>? instance) => 
    instance?.map((e) => e.toJson()).toList();

List<ProjectExperienceDTO>? _projectExperiencesFromJson(List<dynamic>? json) => 
    json?.map((e) => ProjectExperienceDTO.fromJson(e as Map<String, dynamic>)).toList();

List<dynamic>? _projectExperiencesToJson(List<ProjectExperienceDTO>? instance) => 
    instance?.map((e) => e.toJson()).toList();

List<ResumeSkillDTO>? _skillsFromJson(List<dynamic>? json) => 
    json?.map((e) => ResumeSkillDTO.fromJson(e as Map<String, dynamic>)).toList();

List<dynamic>? _skillsToJson(List<ResumeSkillDTO>? instance) => 
    instance?.map((e) => e.toJson()).toList(); 
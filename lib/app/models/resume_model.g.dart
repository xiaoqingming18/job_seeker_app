// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeDTO _$ResumeDTOFromJson(Map<String, dynamic> json) => ResumeDTO(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: json['status'] as String?,
      isDefault: json['isDefault'] as bool?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$ResumeDTOToJson(ResumeDTO instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'status': instance.status,
      'isDefault': instance.isDefault,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
    };

OnlineResumeDTO _$OnlineResumeDTOFromJson(Map<String, dynamic> json) =>
    OnlineResumeDTO(
      id: (json['id'] as num?)?.toInt(),
      resumeId: (json['resumeId'] as num?)?.toInt(),
      resumeInfo: json['resumeInfo'] == null
          ? null
          : ResumeDTO.fromJson(json['resumeInfo'] as Map<String, dynamic>),
      realName: json['realName'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      highestEducation: json['highestEducation'] as String?,
      workYears: (json['workYears'] as num?)?.toInt(),
      selfDescription: json['selfDescription'] as String?,
      jobIntention: json['jobIntention'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      expectedCity: json['expectedCity'] as String?,
      avatar: json['avatar'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      workExperiences: (json['workExperiences'] as List<dynamic>?)
          ?.map((e) => WorkExperienceDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      educationExperiences: (json['educationExperiences'] as List<dynamic>?)
          ?.map(
              (e) => EducationExperienceDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      projectExperiences: (json['projectExperiences'] as List<dynamic>?)
          ?.map((e) => ProjectExperienceDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => ResumeSkillDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OnlineResumeDTOToJson(OnlineResumeDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'resumeInfo': instance.resumeInfo,
      'realName': instance.realName,
      'gender': instance.gender,
      'birthDate': instance.birthDate,
      'phone': instance.phone,
      'email': instance.email,
      'highestEducation': instance.highestEducation,
      'workYears': instance.workYears,
      'selfDescription': instance.selfDescription,
      'jobIntention': instance.jobIntention,
      'expectedSalary': instance.expectedSalary,
      'expectedCity': instance.expectedCity,
      'avatar': instance.avatar,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'workExperiences': instance.workExperiences,
      'educationExperiences': instance.educationExperiences,
      'projectExperiences': instance.projectExperiences,
      'skills': instance.skills,
    };

AttachmentResumeDTO _$AttachmentResumeDTOFromJson(Map<String, dynamic> json) =>
    AttachmentResumeDTO(
      id: (json['id'] as num?)?.toInt(),
      resumeId: (json['resumeId'] as num?)?.toInt(),
      resumeInfo: json['resumeInfo'] == null
          ? null
          : ResumeDTO.fromJson(json['resumeInfo'] as Map<String, dynamic>),
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      fileType: json['fileType'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$AttachmentResumeDTOToJson(
        AttachmentResumeDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'resumeInfo': instance.resumeInfo,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'fileSize': instance.fileSize,
      'fileType': instance.fileType,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
    };

WorkExperienceDTO _$WorkExperienceDTOFromJson(Map<String, dynamic> json) =>
    WorkExperienceDTO(
      id: (json['id'] as num?)?.toInt(),
      resumeId: (json['resumeId'] as num?)?.toInt(),
      companyName: json['companyName'] as String?,
      position: json['position'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      description: json['description'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$WorkExperienceDTOToJson(WorkExperienceDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'companyName': instance.companyName,
      'position': instance.position,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'description': instance.description,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
    };

EducationExperienceDTO _$EducationExperienceDTOFromJson(
        Map<String, dynamic> json) =>
    EducationExperienceDTO(
      id: (json['id'] as num?)?.toInt(),
      resumeId: (json['resumeId'] as num?)?.toInt(),
      schoolName: json['schoolName'] as String?,
      major: json['major'] as String?,
      degree: json['degree'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$EducationExperienceDTOToJson(
        EducationExperienceDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'schoolName': instance.schoolName,
      'major': instance.major,
      'degree': instance.degree,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
    };

ProjectExperienceDTO _$ProjectExperienceDTOFromJson(
        Map<String, dynamic> json) =>
    ProjectExperienceDTO(
      id: (json['id'] as num?)?.toInt(),
      resumeId: (json['resumeId'] as num?)?.toInt(),
      projectName: json['projectName'] as String?,
      role: json['role'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      description: json['description'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$ProjectExperienceDTOToJson(
        ProjectExperienceDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'projectName': instance.projectName,
      'role': instance.role,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'description': instance.description,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
    };

ResumeSkillDTO _$ResumeSkillDTOFromJson(Map<String, dynamic> json) =>
    ResumeSkillDTO(
      id: (json['id'] as num?)?.toInt(),
      resumeId: (json['resumeId'] as num?)?.toInt(),
      occupationId: (json['occupationId'] as num?)?.toInt(),
      occupationName: json['occupationName'] as String?,
      proficiency: json['proficiency'] as String?,
      createTime: json['createTime'] as String?,
    );

Map<String, dynamic> _$ResumeSkillDTOToJson(ResumeSkillDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'occupationId': instance.occupationId,
      'occupationName': instance.occupationName,
      'proficiency': instance.proficiency,
      'createTime': instance.createTime,
    };

OnlineResumeCreateDTO _$OnlineResumeCreateDTOFromJson(
        Map<String, dynamic> json) =>
    OnlineResumeCreateDTO(
      resumeInfo:
          _resumeCreateDTOFromJson(json['resumeInfo'] as Map<String, dynamic>),
      realName: json['realName'] as String,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      highestEducation: json['highestEducation'] as String?,
      workYears: (json['workYears'] as num?)?.toInt(),
      selfDescription: json['selfDescription'] as String?,
      jobIntention: json['jobIntention'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      expectedCity: json['expectedCity'] as String?,
      avatar: json['avatar'] as String?,
      workExperiences:
          _workExperiencesFromJson(json['workExperiences'] as List?),
      educationExperiences:
          _educationExperiencesFromJson(json['educationExperiences'] as List?),
      projectExperiences:
          _projectExperiencesFromJson(json['projectExperiences'] as List?),
      skills: _skillsFromJson(json['skills'] as List?),
    );

Map<String, dynamic> _$OnlineResumeCreateDTOToJson(
        OnlineResumeCreateDTO instance) =>
    <String, dynamic>{
      'resumeInfo': _resumeCreateDTOToJson(instance.resumeInfo),
      'realName': instance.realName,
      'gender': instance.gender,
      'birthDate': instance.birthDate,
      'phone': instance.phone,
      'email': instance.email,
      'highestEducation': instance.highestEducation,
      'workYears': instance.workYears,
      'selfDescription': instance.selfDescription,
      'jobIntention': instance.jobIntention,
      'expectedSalary': instance.expectedSalary,
      'expectedCity': instance.expectedCity,
      'avatar': instance.avatar,
      'workExperiences': _workExperiencesToJson(instance.workExperiences),
      'educationExperiences':
          _educationExperiencesToJson(instance.educationExperiences),
      'projectExperiences':
          _projectExperiencesToJson(instance.projectExperiences),
      'skills': _skillsToJson(instance.skills),
    };

AttachmentResumeCreateDTO _$AttachmentResumeCreateDTOFromJson(
        Map<String, dynamic> json) =>
    AttachmentResumeCreateDTO(
      resumeInfo:
          _resumeCreateDTOFromJson(json['resumeInfo'] as Map<String, dynamic>),
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      fileType: json['fileType'] as String,
    );

Map<String, dynamic> _$AttachmentResumeCreateDTOToJson(
        AttachmentResumeCreateDTO instance) =>
    <String, dynamic>{
      'resumeInfo': _resumeCreateDTOToJson(instance.resumeInfo),
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'fileSize': instance.fileSize,
      'fileType': instance.fileType,
    };

OnlineResumeUpdateDTO _$OnlineResumeUpdateDTOFromJson(
        Map<String, dynamic> json) =>
    OnlineResumeUpdateDTO(
      id: (json['id'] as num).toInt(),
      resumeInfo:
          _resumeUpdateDTOFromJson(json['resumeInfo'] as Map<String, dynamic>),
      realName: json['realName'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      highestEducation: json['highestEducation'] as String?,
      workYears: (json['workYears'] as num?)?.toInt(),
      selfDescription: json['selfDescription'] as String?,
      jobIntention: json['jobIntention'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
      expectedCity: json['expectedCity'] as String?,
      avatar: json['avatar'] as String?,
      workExperiences:
          _workExperiencesFromJson(json['workExperiences'] as List?),
      educationExperiences:
          _educationExperiencesFromJson(json['educationExperiences'] as List?),
      projectExperiences:
          _projectExperiencesFromJson(json['projectExperiences'] as List?),
      skills: _skillsFromJson(json['skills'] as List?),
    );

Map<String, dynamic> _$OnlineResumeUpdateDTOToJson(
        OnlineResumeUpdateDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeInfo': _resumeUpdateDTOToJson(instance.resumeInfo),
      'realName': instance.realName,
      'gender': instance.gender,
      'birthDate': instance.birthDate,
      'phone': instance.phone,
      'email': instance.email,
      'highestEducation': instance.highestEducation,
      'workYears': instance.workYears,
      'selfDescription': instance.selfDescription,
      'jobIntention': instance.jobIntention,
      'expectedSalary': instance.expectedSalary,
      'expectedCity': instance.expectedCity,
      'avatar': instance.avatar,
      'workExperiences': _workExperiencesToJson(instance.workExperiences),
      'educationExperiences':
          _educationExperiencesToJson(instance.educationExperiences),
      'projectExperiences':
          _projectExperiencesToJson(instance.projectExperiences),
      'skills': _skillsToJson(instance.skills),
    };

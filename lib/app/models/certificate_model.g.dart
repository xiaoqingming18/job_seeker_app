// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// 辅助函数，用于解码可空的枚举值
T? $enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return $enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

// 辅助函数，用于解码枚举值
T $enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  for (var entry in enumValues.entries) {
    if (entry.value == source) {
      return entry.key;
    }
  }

  if (unknownValue == null) {
    throw ArgumentError(
        'Unknown enum value: $source. Supported values: ${enumValues.values.join(', ')}');
  }

  return unknownValue;
}

Certificate _$CertificateFromJson(Map<String, dynamic> json) => Certificate(
      id: json['id'] as int?,
      jobSeekerId: json['jobSeekerId'] as int?,
      jobSeekerName: json['jobSeekerName'] as String?,
      certificateName: json['certificateName'] as String,
      certificateNo: json['certificateNo'] as String?,
      certificateTypeId: json['certificateTypeId'] as int?,
      certificateTypeName: json['certificateTypeName'] as String?,
      issuingAuthority: json['issuingAuthority'] as String?,
      issueDate: json['issueDate'] == null
          ? null
          : DateTime.parse(json['issueDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      imageUrl: json['imageUrl'] as String?,
      status: $enumDecodeNullable(_$CertificateStatusEnumMap, json['verificationStatus']) ??
          CertificateStatus.pending,
      verificationComment: json['verificationComment'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$CertificateToJson(Certificate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobSeekerId': instance.jobSeekerId,
      'jobSeekerName': instance.jobSeekerName,
      'certificateName': instance.certificateName,
      'certificateNo': instance.certificateNo,
      'certificateTypeId': instance.certificateTypeId,
      'certificateTypeName': instance.certificateTypeName,
      'issuingAuthority': instance.issuingAuthority,
      'issueDate': instance.issueDate?.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'imageUrl': instance.imageUrl,
      'verificationStatus': _$CertificateStatusEnumMap[instance.status],
      'verificationComment': instance.verificationComment,
      'createTime': instance.createTime?.toIso8601String(),
      'updateTime': instance.updateTime?.toIso8601String(),
    };

const _$CertificateStatusEnumMap = {
  CertificateStatus.pending: 'pending',
  CertificateStatus.verified: 'verified',
  CertificateStatus.rejected: 'rejected',
};

CertificateType _$CertificateTypeFromJson(Map<String, dynamic> json) =>
    CertificateType(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String?,
      issuingAuthority: json['issuingAuthority'] as String?,
      validityYears: json['validityYears'] as int?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      status: json['status'] as int? ?? 1,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$CertificateTypeToJson(CertificateType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'issuingAuthority': instance.issuingAuthority,
      'validityYears': instance.validityYears,
      'icon': instance.icon,
      'description': instance.description,
      'status': instance.status,
      'createTime': instance.createTime?.toIso8601String(),
      'updateTime': instance.updateTime?.toIso8601String(),
    };

CertificateListResponse _$CertificateListResponseFromJson(
        Map<String, dynamic> json) =>
    CertificateListResponse(
      records: (json['records'] as List<dynamic>)
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      size: json['size'] as int,
      current: json['current'] as int,
    );

Map<String, dynamic> _$CertificateListResponseToJson(
        CertificateListResponse instance) =>
    <String, dynamic>{
      'records': instance.records,
      'total': instance.total,
      'size': instance.size,
      'current': instance.current,
    };

CertificateTypeListResponse _$CertificateTypeListResponseFromJson(
        Map<String, dynamic> json) =>
    CertificateTypeListResponse(
      records: (json['records'] as List<dynamic>)
          .map((e) => CertificateType.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      size: json['size'] as int,
      current: json['current'] as int,
    );

Map<String, dynamic> _$CertificateTypeListResponseToJson(
        CertificateTypeListResponse instance) =>
    <String, dynamic>{
      'records': instance.records,
      'total': instance.total,
      'size': instance.size,
      'current': instance.current,
    }; 
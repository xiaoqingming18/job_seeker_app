import 'package:json_annotation/json_annotation.dart';

part 'occupation_model.g.dart';

/// 工种模型
@JsonSerializable()
class OccupationModel {
  final int id;
  final String name;
  final int categoryId;
  final String? icon;
  final String? description;
  final List<String>? requiredCertificates;
  final double averageDailyWage;
  final int difficultyLevel;
  final int status;
  final String? createTime;
  final String? updateTime;
  final String? categoryName;

  OccupationModel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.icon,
    this.description,
    this.requiredCertificates,
    required this.averageDailyWage,
    required this.difficultyLevel,
    required this.status,
    this.createTime,
    this.updateTime,
    this.categoryName,
  });

  /// 从JSON映射到对象
  factory OccupationModel.fromJson(Map<String, dynamic> json) => _$OccupationModelFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$OccupationModelToJson(this);
}

/// 热门工种响应模型
@JsonSerializable()
class HotOccupationsResponse {
  final List<OccupationModel> data;

  HotOccupationsResponse({
    required this.data,
  });

  /// 从JSON映射到对象
  factory HotOccupationsResponse.fromJson(Map<String, dynamic> json) => 
      _$HotOccupationsResponseFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$HotOccupationsResponseToJson(this);
} 
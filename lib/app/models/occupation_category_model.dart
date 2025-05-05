import 'package:flutter/foundation.dart';

/// 工种类别模型
class OccupationCategoryModel {
  final int id;
  final String name;
  final String? description;
  final int? displayOrder;
  final int? status;
  final String? createTime;
  final String? updateTime;

  OccupationCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.displayOrder,
    this.status,
    this.createTime,
    this.updateTime,
  });

  /// 从JSON映射到对象
  factory OccupationCategoryModel.fromJson(Map<String, dynamic> json) => 
      OccupationCategoryModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        displayOrder: json['displayOrder'] as int?,
        status: json['status'] as int?,
        createTime: json['createTime'] as String?,
        updateTime: json['updateTime'] as String?,
      );

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'displayOrder': displayOrder,
    'status': status,
    'createTime': createTime,
    'updateTime': updateTime,
  };

  @override
  String toString() => 'OccupationCategoryModel(id: $id, name: $name)';
} 
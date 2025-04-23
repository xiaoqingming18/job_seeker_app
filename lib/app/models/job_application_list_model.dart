import 'package:json_annotation/json_annotation.dart';

part 'job_application_list_model.g.dart';

/// 申请列表模型
@JsonSerializable()
class JobApplicationListModel {
  final List<JobApplicationItem> list;
  final int total;
  final int pageNum;
  final int pageSize;
  final int totalPages;

  JobApplicationListModel({
    required this.list,
    required this.total,
    required this.pageNum,
    required this.pageSize,
    required this.totalPages,
  });

  /// 从JSON映射到对象
  factory JobApplicationListModel.fromJson(Map<String, dynamic> json) => 
      _$JobApplicationListModelFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$JobApplicationListModelToJson(this);
}

/// 单个申请项模型
@JsonSerializable()
class JobApplicationItem {
  final int id;
  final int jobSeekerId;
  final String jobSeekerName;
  final int demandId;
  final String demandTitle;
  final String? expectedEntryDate;
  final double? expectedSalary;
  final String status;
  final String createTime;

  JobApplicationItem({
    required this.id,
    required this.jobSeekerId,
    required this.jobSeekerName,
    required this.demandId,
    required this.demandTitle,
    this.expectedEntryDate,
    this.expectedSalary,
    required this.status,
    required this.createTime,
  });

  /// 从JSON映射到对象
  factory JobApplicationItem.fromJson(Map<String, dynamic> json) => 
      _$JobApplicationItemFromJson(json);

  /// 从对象映射到JSON
  Map<String, dynamic> toJson() => _$JobApplicationItemToJson(this);

  /// 获取状态显示文本
  String getStatusText() {
    switch (status) {
      case 'applied':
        return '已申请';
      case 'processing':
        return '处理中';
      case 'interview':
        return '面试中';
      case 'accepted':
        return '已录用';
      case 'rejected':
        return '已拒绝';
      case 'cancelled':
        return '已取消';
      default:
        return '未知状态';
    }
  }

  /// 获取状态显示颜色
  String getStatusColor() {
    switch (status) {
      case 'applied':
        return '#3498db'; // 蓝色
      case 'processing':
        return '#f39c12'; // 橙色
      case 'interview':
        return '#9b59b6'; // 紫色
      case 'accepted':
        return '#2ecc71'; // 绿色
      case 'rejected':
        return '#e74c3c'; // 红色
      case 'cancelled':
        return '#95a5a6'; // 灰色
      default:
        return '#95a5a6'; // 灰色
    }
  }
} 
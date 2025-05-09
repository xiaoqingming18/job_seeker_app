/// 请假状态枚举
import 'package:intl/intl.dart';

enum LeaveStatus {
  pending,  // 待审批
  
  approved, // 已批准
  
  rejected, // 已拒绝
  
  cancelled // 已取消
}

/// 请假类型枚举
enum LeaveType {
  sick,       // 病假
  
  personal,   // 事假
  
  annual,     // 年假
  
  other       // 其他
}

/// 请假模型
class LeaveModel {
  /// 请假记录ID
  final int? id;
  
  /// 项目ID
  final int projectId;
  
  /// 项目名称
  final String? projectName;
  
  /// 请假类型
  final LeaveType type;
  
  /// 请假状态
  final LeaveStatus status;
  
  /// 开始时间
  final DateTime startTime;
  
  /// 结束时间
  final DateTime endTime;
  
  /// 请假原因
  final String reason;
  
  /// 提交时间
  final DateTime? createTime;
  
  /// 附件URL（可选）
  final List<String>? attachments;
  
  /// 审批人ID
  final int? approverId;
  
  /// 审批人姓名
  final String? approverName;
  
  /// 审批时间
  final DateTime? approveTime;
  
  /// 审批备注
  final String? approveRemark;

  /// 构造函数
  LeaveModel({
    this.id,
    required this.projectId,
    this.projectName,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.createTime,
    this.attachments,
    this.approverId,
    this.approverName,
    this.approveTime,
    this.approveRemark,
  });

  /// 从JSON转换为模型
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    // 调试输出完整的JSON数据结构
    print('LeaveModel解析JSON: ${json.keys.join(", ")}');
    
    LeaveType parseType(dynamic value) {
      if (value is String) {
        return LeaveType.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
          orElse: () => LeaveType.other,
        );
      } else if (value is int) {
        // 如果是数字类型，尝试根据索引匹配
        final index = value.clamp(0, LeaveType.values.length - 1);
        return LeaveType.values[index];
      }
      return LeaveType.other;
    }
    
    LeaveStatus parseStatus(dynamic value) {
      if (value is String) {
        // 处理后端可能返回的各种状态值
        switch(value.toLowerCase()) {
          case 'pending': return LeaveStatus.pending;
          case 'first_approved': // 一级审批通过，但显示为pending
          case 'waiting': return LeaveStatus.pending;
          case 'approved': return LeaveStatus.approved;
          case 'rejected': return LeaveStatus.rejected;
          case 'cancelled': return LeaveStatus.cancelled;
          default: return LeaveStatus.pending;
        }
      } else if (value is int) {
        // 如果是数字类型，尝试根据索引匹配
        final index = value.clamp(0, LeaveStatus.values.length - 1);
        return LeaveStatus.values[index];
      }
      return LeaveStatus.pending;
    }
    
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          try {
            // 尝试其他日期格式
            final dateFormats = [
              'yyyy-MM-dd',
              'yyyy/MM/dd',
              'yyyy-MM-dd HH:mm:ss',
              'yyyy/MM/dd HH:mm:ss',
            ];
            
            for (final format in dateFormats) {
              try {
                return DateFormat(format).parse(value);
              } catch (_) {
                // 忽略解析错误，尝试下一个格式
              }
            }
            return null;
          } catch (_) {
            return null;
          }
        }
      } else if (value is int) {
        // 处理时间戳
        try {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }
    
    List<String>? parseAttachments(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      } else if (value is String && value.isNotEmpty) {
        // 尝试解析可能是JSON字符串的附件
        try {
          return [value];
        } catch (_) {
          return null;
        }
      }
      return null;
    }
    
    try {
      // 字段映射以适应后端API返回的不同字段名
      final id = json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '') ?? null);
      final projectId = json['projectId'] is int ? json['projectId'] as int : 
                        (int.tryParse(json['projectId']?.toString() ?? '') ?? 0);
      final projectName = json['projectName'] as String?;
      final userId = json['userId'] is int ? json['userId'] as int : 
                    (int.tryParse(json['userId']?.toString() ?? '') ?? null);
      final userName = json['userName'] as String?;
      
      // 处理请假类型 - 可能是leaveType或type
      final typeValue = json['leaveType'] ?? json['type'];
      final type = parseType(typeValue);
      
      // 处理状态 - status字段
      final status = parseStatus(json['status']);
      
      // 处理开始日期 - 可能是startTime、startDate或start_date字段
      final startTimeValue = json['startTime'] ?? json['startDate'] ?? json['start_date'];
      final startTime = parseDateTime(startTimeValue) ?? DateTime.now();
      
      // 处理结束日期 - 可能是endTime、endDate或end_date字段 
      final endTimeValue = json['endTime'] ?? json['endDate'] ?? json['end_date'];
      final endTime = parseDateTime(endTimeValue) ?? DateTime.now();
      
      // 处理请假原因
      final reason = json['reason'] as String? ?? '';
      
      // 处理创建时间 - 可能是createTime、application_time或applicationTime字段
      final createTimeValue = json['createTime'] ?? json['applicationTime'] ?? json['application_time'] ?? json['createDate'];
      final createTime = parseDateTime(createTimeValue);
      
      // 处理附件
      final attachments = parseAttachments(json['attachments']);
      
      // 提取审批信息，处理不同的字段命名方式
      Map<String, dynamic> extractApprovalInfo(Map<String, dynamic> json, List<String> prefix) {
        final info = <String, dynamic>{};
        
        for (final pre in prefix) {
          // 尝试提取审批人ID
          if (json['${pre}ApproverId'] != null) {
            info['approverId'] = json['${pre}ApproverId'] is int ? 
                                json['${pre}ApproverId'] : 
                                int.tryParse(json['${pre}ApproverId']?.toString() ?? '');
          }
          
          // 尝试提取审批人姓名
          if (json['${pre}ApproverName'] != null) {
            info['approverName'] = json['${pre}ApproverName']?.toString();
          }
          
          // 尝试提取审批时间
          if (json['${pre}ApprovalTime'] != null) {
            final timeValue = json['${pre}ApprovalTime'];
            info['approveTime'] = parseDateTime(timeValue);
          }
          
          // 尝试提取审批备注
          if (json['${pre}ApprovalComments'] != null) {
            info['approveRemark'] = json['${pre}ApprovalComments']?.toString();
          } else if (json['${pre}ApprovalRemark'] != null) {
            info['approveRemark'] = json['${pre}ApprovalRemark']?.toString();
          }
          
          // 如果已经找到有效的审批信息，就停止查找
          if (info['approverId'] != null || info['approverName'] != null) {
            break;
          }
        }
        
        return info;
      }
      
      // 尝试不同的字段前缀来查找审批信息
      final prefixes = ['pm', 'admin', 'hr', ''];
      final approvalInfo = extractApprovalInfo(json, prefixes);
      
      final approverId = approvalInfo['approverId'] as int?;
      final approverName = approvalInfo['approverName'] as String?;
      final approveTime = approvalInfo['approveTime'] as DateTime?;
      final approveRemark = approvalInfo['approveRemark'] as String?;
      
      print('LeaveModel解析成功: id=$id, projectId=$projectId, type=$type, status=$status');
      
      return LeaveModel(
        id: id,
        projectId: projectId,
        projectName: projectName,
        type: type,
        status: status,
        startTime: startTime,
        endTime: endTime,
        reason: reason,
        createTime: createTime,
        attachments: attachments,
        approverId: approverId,
        approverName: approverName,
        approveTime: approveTime,
        approveRemark: approveRemark,
      );
    } catch (e) {
      print('LeaveModel解析异常: $e，原始JSON: $json');
      // 返回最简单的模型，避免空指针异常
      return LeaveModel(
        id: json['id'] is int ? json['id'] as int : null,
        projectId: json['projectId'] is int ? json['projectId'] as int : 0,
        projectName: json['projectName'] as String?,
        type: LeaveType.other,
        status: LeaveStatus.pending,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 1)),
        reason: json['reason'] as String? ?? '无原因',
      );
    }
  }

  /// 从模型转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'reason': reason,
      'createTime': createTime?.toIso8601String(),
      'attachments': attachments,
      'approverId': approverId,
      'approverName': approverName,
      'approveTime': approveTime?.toIso8601String(),
      'approveRemark': approveRemark,
    };
  }
}

/// 请假请求模型
class LeaveRequestModel {
  /// 项目ID
  final int projectId;
  
  /// 请假类型
  final LeaveType type;
  
  /// 开始时间
  final DateTime startTime;
  
  /// 结束时间
  final DateTime endTime;
  
  /// 请假原因
  final String reason;
  
  /// 附件URL列表（可选）
  final List<String>? attachments;

  /// 构造函数
  LeaveRequestModel({
    required this.projectId,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.attachments,
  });

  /// 从JSON转换为模型
  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    LeaveType parseType(dynamic value) {
      if (value is String) {
        return LeaveType.values.firstWhere(
          (e) => e.toString().split('.').last == value,
          orElse: () => LeaveType.other,
        );
      }
      return LeaveType.other;
    }
    
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }
    
    List<String>? parseAttachments(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return null;
    }
    
    return LeaveRequestModel(
      projectId: json['projectId'] as int? ?? 0,
      type: parseType(json['type']),
      startTime: parseDateTime(json['startTime']),
      endTime: parseDateTime(json['endTime']),
      reason: json['reason'] as String? ?? '',
      attachments: parseAttachments(json['attachments']),
    );
  }

  /// 从模型转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'type': type.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'reason': reason,
      'attachments': attachments,
    };
  }
} 
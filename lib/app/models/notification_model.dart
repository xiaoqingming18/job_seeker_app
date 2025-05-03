import 'dart:convert';

/// WebSocket 系统通知模型
/// 用于解析接收到的 WebSocket 系统通知消息
class NotificationModel {
  /// 通知所属模块
  final String type;
  
  /// 消息标题
  final String title;
  
  /// 消息内容
  final String content;
  
  /// 携带的数据，JSON 格式
  final Map<String, dynamic>? data;
  
  /// 创建时间戳
  final DateTime timestamp;

  NotificationModel({
    required this.type,
    required this.title,
    required this.content,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 从 JSON 数据创建通知模型
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      data: json['data'] != null 
          ? (json['data'] is Map 
              ? json['data'] as Map<String, dynamic> 
              : jsonDecode(json['data'].toString()))
          : null,
      timestamp: DateTime.now(),
    );
  }
  
  /// 将通知模型转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'NotificationModel(type: $type, title: $title, content: $content, data: $data, timestamp: $timestamp)';
  }
    /// 比较两个通知是否相似（用于检查重复）
  bool isSimilarTo(NotificationModel other) {
    // 对于合同通知，如果类型、标题和合同代码相同，则认为是相似通知
    if (type == NotificationType.contract && other.type == NotificationType.contract) {
      final String? thisContractCode = data?['contractCode'];
      final String? otherContractCode = other.data?['contractCode'];
      
      if (thisContractCode != null && otherContractCode != null) {
        return thisContractCode == otherContractCode;
      }
    }
    
    // 对于面试通知，如果类型、子类型和面试ID相同，则认为是相似通知
    if (type == NotificationType.interview && other.type == NotificationType.interview) {
      final String? thisInterviewId = data?['interviewId'];
      final String? otherInterviewId = other.data?['interviewId'];
      final String? thisType = data?['type'];
      final String? otherType = other.data?['type'];
      
      if (thisInterviewId != null && otherInterviewId != null && 
          thisType != null && otherType != null) {
        return thisInterviewId == otherInterviewId && thisType == otherType;
      }
    }
    
    // 对于其他类型的通知，可以根据需要添加更多规则
    return false;
  }
}

/// 通知类型枚举
/// 用于标识不同类型的通知
class NotificationType {
  // 用户相关通知
  static const String user = 'user';
  
  // 工作相关通知
  static const String job = 'job';
  
  // 应用相关通知
  static const String app = 'app';
  
  // 系统相关通知
  static const String system = 'system';
  
  // 面试相关通知
  static const String interview = 'interview';
  
  // 消息相关通知
  static const String message = 'message';
  
  // 合同相关通知
  static const String contract = 'contract';
}

/// 通知管理器
/// 用于处理接收到的通知
class NotificationManager {
  // 存储已接收的通知
  final List<NotificationModel> _notifications = [];
  
  // 获取所有通知
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  
  // 添加通知，检查重复
  void addNotification(NotificationModel notification) {
    // 优先检查是否为合同类型通知，并且是否已有相似通知
    if (notification.type == NotificationType.contract) {
      // 查找现有相似通知
      int existingIndex = _findSimilarNotificationIndex(notification);
      
      if (existingIndex >= 0) {
        // 如果找到了相似通知，替换它（而不是添加新的）
        _notifications[existingIndex] = notification;
        print('更新现有合同通知，而非添加新通知');
        return;
      }
      
      // 限制合同通知的总数，如果已经很多，则移除最旧的
      final contractNotifications = _notifications
          .where((n) => n.type == NotificationType.contract)
          .toList();
      
      if (contractNotifications.length >= 10) {
        // 找出最老的合同通知并移除
        contractNotifications.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final oldestContract = contractNotifications.first;
        _notifications.remove(oldestContract);
        print('达到合同通知数量上限，移除最旧的通知');
      }
    }
    
    // 添加新通知
    _notifications.add(notification);
  }
  
  // 查找相似通知的索引
  int _findSimilarNotificationIndex(NotificationModel notification) {
    for (int i = 0; i < _notifications.length; i++) {
      if (notification.isSimilarTo(_notifications[i])) {
        return i;
      }
    }
    return -1;
  }
  
  // 添加通知（从原始JSON数据）
  void addNotificationFromJson(Map<String, dynamic> json) {
    try {
      final notification = NotificationModel.fromJson(json);
      addNotification(notification);
    } catch (e) {
      print('解析通知数据失败: $e');
    }
  }
  
  // 清除所有通知
  void clearNotifications() {
    _notifications.clear();
  }
  
  // 按类型获取通知
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }
  
  // 获取最近的通知，可以指定数量
  List<NotificationModel> getRecentNotifications({int count = 5}) {
    final sortedList = List<NotificationModel>.from(_notifications)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return sortedList.take(count).toList();
  }
}
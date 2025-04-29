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
  
  // 添加通知
  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
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
import 'package:get/get.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import 'socket_service.dart';

/// 通知服务
/// 用于处理系统通知并提供通知相关功能
class NotificationService extends GetxService {
  // 通知管理器
  final NotificationManager _notificationManager = NotificationManager();
  
  // 最新通知
  final Rx<NotificationModel?> latestNotification = Rx<NotificationModel?>(null);
  
  // 未读通知数量
  final RxInt unreadCount = 0.obs;
  
  // 通知列表
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  
  // Socket 服务
  final SocketService _socketService = Get.find<SocketService>();
  
  /// 初始化通知服务
  Future<NotificationService> init() async {
    // 初始设置通知监听
    _setupNotificationListeners();
    
    // 监听Socket连接状态变化
    _socketService.isConnected.listen((connected) {
      if (connected) {
        // 当WebSocket连接成功时，重新设置通知监听
        print('WebSocket连接已建立，重新设置通知监听...');
        _setupNotificationListeners();
      }
    });
    
    return this;
  }
    /// 设置通知监听
  void _setupNotificationListeners() {
    // 监听系统通知事件
    _socketService.on('notification', _handleNotification);
    
    // 可以添加其他特定类型的通知监听
    _socketService.on('user_notification', _handleNotification);
    _socketService.on('job_notification', _handleNotification);
    
    // 监听合同通知事件
    _socketService.on('contract_notification', _handleNotification);
    
    // 监听面试通知事件
    _socketService.on('interview_notification', _handleNotification);
    
    print('通知监听已设置：notification, user_notification, job_notification, contract_notification, interview_notification');
    
    // 主动尝试发送一个测试消息到WebSocket服务器
    try {
      _socketService.emit('subscribe_events', {
        'events': ['contract_notification', 'interview_notification']
      });
      print('已发送合同通知和面试通知订阅请求');
    } catch (e) {
      print('发送订阅请求失败: $e');
    }
  }
  
  /// 处理接收到的通知
  void _handleNotification(dynamic data) {
    try {
      print('接收到通知: $data');
      
      // 解析通知数据
      Map<String, dynamic> notificationData;
      
      if (data is String) {
        // 如果接收到的是字符串，尝试解析 JSON
        notificationData = jsonDecode(data);
      } else if (data is Map) {
        // 如果直接是 Map 对象
        notificationData = Map<String, dynamic>.from(data);
      } else {
        print('无法识别的通知数据格式: ${data.runtimeType}');
        return;
      }
      
      // 创建通知模型
      final notification = NotificationModel.fromJson(notificationData);
      
      // 添加到通知管理器
      _notificationManager.addNotification(notification);
      
      // 更新最新通知
      latestNotification.value = notification;
      
      // 更新通知列表
      _updateNotificationsList();
      
      // 增加未读数量
      unreadCount.value++;
      
      // 可以在这里添加本地通知显示逻辑
    } catch (e) {
      print('处理通知时出错: $e');
      print('异常详情: ${e.toString()}');
      print('原始数据: $data');
    }
  }
  
  /// 更新通知列表
  void _updateNotificationsList() {
    notifications.value = List.from(_notificationManager.notifications);
  }
  
  /// 标记所有通知为已读
  void markAllAsRead() {
    unreadCount.value = 0;
  }
  
  /// 获取特定类型的通知
  List<NotificationModel> getNotificationsByType(String type) {
    return _notificationManager.getNotificationsByType(type);
  }
  
  /// 清除所有通知
  void clearAllNotifications() {
    _notificationManager.clearNotifications();
    notifications.clear();
    unreadCount.value = 0;
  }
  
  /// 获取最近通知
  List<NotificationModel> getRecentNotifications({int count = 5}) {
    return _notificationManager.getRecentNotifications(count: count);
  }
  
  /// 发送合同通知测试（用于测试）
  void sendTestContractNotification({bool isResign = false}) {
    final contractType = isResign ? 'reSign' : 'sign';
    final contractCode = '20250428${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 11)}';
    final title = isResign ? '合同续签' : '合同签订';
    final content = '您有一份劳务合同待${isResign ? '续签' : '签署'}，合同编号：$contractCode';
    
    final testNotification = {
      'type': NotificationType.contract,
      'title': title,
      'content': content,
      'data': {
        'contractCode': contractCode,
        'type': contractType
      }
    };
    
    _handleNotification(testNotification);
  }
  
  /// 发送面试通知测试（用于测试）
  void sendTestInterviewNotification({String subType = 'arrange'}) {
    final interviewId = DateTime.now().millisecondsSinceEpoch.toString().substring(5, 11);
    String title, content;
    Map<String, dynamic> data;
    
    if (subType == 'arrange') {
      title = '面试通知';
      content = '您有一场面试安排于明天下午14:00，请准时参加';
      data = {
        'type': 'arrange',
        'interviewId': interviewId,
        'status': 'scheduled',
        'interviewDate': '${DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10)} 14:00',
        'location': '中建三局总部15楼'
      };
    } else {
      title = '面试结果';
      content = '您的面试结果已出：通过';
      data = {
        'type': 'result',
        'interviewId': interviewId,
        'status': 'completed',
        'result': 'pass'
      };
    }
    
    final testNotification = {
      'type': NotificationType.interview,
      'title': title,
      'content': content,
      'data': data
    };
    
    _handleNotification(testNotification);
  }

  @override
  void onClose() {
    // 取消所有通知的监听
    _socketService.off('notification');
    _socketService.off('user_notification');
    _socketService.off('job_notification');
    _socketService.off('contract_notification');
    _socketService.off('interview_notification');
    super.onClose();
  }
}
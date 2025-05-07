import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';

/// 全局通知弹窗 Overlay
/// 用于在应用任何页面展示通知消息
class NotificationOverlay {
  // 单例模式
  static final NotificationOverlay _instance = NotificationOverlay._internal();
  factory NotificationOverlay() => _instance;
  NotificationOverlay._internal();

  // 当前显示的弹窗
  OverlayEntry? _currentOverlay;
  
  // 是否正在显示
  bool _isShowing = false;
  
  // 控制通知消息队列
  final List<NotificationModel> _notificationQueue = [];
  
  /// 显示通知
  void show(NotificationModel notification) {
    // 如果已经在显示通知，则将新通知加入队列
    if (_isShowing) {
      _notificationQueue.add(notification);
      return;
    }
    
    _isShowing = true;
    _showOverlay(notification);
  }
  
  /// 显示通知 Overlay
  void _showOverlay(NotificationModel notification) {
    // 移除现有的 overlay
    _removeCurrentOverlay();
    
    // 创建新的 overlay
    _currentOverlay = OverlayEntry(
      builder: (context) => _buildNotificationWidget(notification),
    );
    
    // 将 overlay 添加到 overlay 层
    final overlay = Overlay.of(Get.overlayContext!);
    overlay.insert(_currentOverlay!);
  }
  
  /// 移除当前显示的 overlay
  void _removeCurrentOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }
  
  /// 构建通知 Widget
  Widget _buildNotificationWidget(NotificationModel notification) {
    // 根据通知类型设置不同的图标和颜色
    IconData icon;
    Color iconColor;
    Color bgColor;
    
    switch (notification.type) {
      case NotificationType.contract:
        final isResign = notification.data != null && notification.data!['type'] == 'reSign';
        icon = isResign ? Icons.autorenew : Icons.assignment;
        iconColor = isResign ? Colors.teal : Colors.indigo;
        bgColor = isResign ? Colors.teal.shade50 : Colors.indigo.shade50;
        break;
      case NotificationType.interview:
        final subType = notification.data != null ? notification.data!['type'] : 'arrange';
        if (subType == 'result') {
          icon = Icons.fact_check;
          iconColor = Colors.amber.shade800;
          bgColor = Colors.amber.shade50;
        } else {
          icon = Icons.event_available;
          iconColor = Colors.orange.shade800;
          bgColor = Colors.orange.shade50;
        }
        break;
      case NotificationType.system:
        icon = Icons.announcement;
        iconColor = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case NotificationType.job:
        icon = Icons.work;
        iconColor = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey.shade700;
        bgColor = Colors.grey.shade50;
    }
    
    // 使用一个Stack添加半透明背景
    return Stack(
      children: [
        // 半透明背景层，阻止用户点击后面的内容
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              // 点击背景关闭弹窗
              _removeCurrentOverlay();
              _isShowing = false;
              
              // 如果队列中有更多通知，显示下一个
              if (_notificationQueue.isNotEmpty) {
                final nextNotification = _notificationQueue.removeAt(0);
                show(nextNotification);
              }
            },
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        // 弹窗内容
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(Get.context!).size.width * 0.85,
                maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
              ),
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题栏
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: iconColor, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: iconColor,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // 点击关闭按钮
                              _removeCurrentOverlay();
                              _isShowing = false;
                              
                              // 如果队列中有更多通知，显示下一个
                              if (_notificationQueue.isNotEmpty) {
                                final nextNotification = _notificationQueue.removeAt(0);
                                show(nextNotification);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, size: 20, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 内容区域
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        notification.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    
                    // 底部按钮区域
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 关闭按钮
                          TextButton(
                            onPressed: () {
                              _removeCurrentOverlay();
                              _isShowing = false;
                              
                              // 如果队列中有更多通知，显示下一个
                              if (_notificationQueue.isNotEmpty) {
                                final nextNotification = _notificationQueue.removeAt(0);
                                show(nextNotification);
                              }
                            },
                            child: const Text('关闭'),
                          ),
                          const SizedBox(width: 8),
                          // 查看详情按钮
                          ElevatedButton(
                            onPressed: () {
                              _removeCurrentOverlay();
                              _isShowing = false;
                              _handleNotificationTap(notification);
                              
                              // 如果队列中有更多通知，显示下一个
                              if (_notificationQueue.isNotEmpty) {
                                final nextNotification = _notificationQueue.removeAt(0);
                                show(nextNotification);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: iconColor,
                            ),
                            child: const Text('查看详情'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 处理通知点击事件
  void _handleNotificationTap(NotificationModel notification) {
    // 根据通知类型导航到不同的页面
    switch (notification.type) {
      case NotificationType.contract:
        // 导航到合同详情页
        final contractCode = notification.data?['contractCode'];
        if (contractCode != null) {
          Get.toNamed('/contract/detail', arguments: {'contractCode': contractCode});
        } else {
          Get.toNamed('/contract');
        }
        break;
        
      case NotificationType.interview:
        // 导航到面试详情页
        final interviewId = notification.data?['interviewId'];
        if (interviewId != null) {
          Get.toNamed('/interview/detail', arguments: {'interviewId': interviewId});
        } else {
          Get.toNamed('/interview');
        }
        break;
        
      case NotificationType.job:
        // 导航到工作详情页
        final jobId = notification.data?['jobId'];
        if (jobId != null) {
          Get.toNamed('/job/detail', arguments: {'jobId': jobId});
        } else {
          Get.toNamed('/job');
        }
        break;
        
      default:
        // 默认导航到消息页面
        Get.toNamed('/home', arguments: {'tab': 'messages'});
    }
  }
} 
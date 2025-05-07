import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/notification_service.dart';

/// 通知测试页面
/// 用于测试通知弹窗功能
class NotificationTestView extends StatelessWidget {
  const NotificationTestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取通知服务
    final NotificationService notificationService = Get.find<NotificationService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知功能测试'),
        actions: [
          Obx(() => Switch(
            value: notificationService.showNotificationPopup.value,
            onChanged: (value) {
              notificationService.setShowNotificationPopup(value);
            },
          )),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('通知弹窗控制', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Obx(() => Row(
                        children: [
                          const Text('启用通知弹窗:'),
                          const Spacer(),
                          Switch(
                            value: notificationService.showNotificationPopup.value,
                            onChanged: (value) {
                              notificationService.setShowNotificationPopup(value);
                            },
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 合同通知测试
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('合同通知测试', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                notificationService.sendTestContractNotification(isResign: false);
                              },
                              child: const Text('合同签订通知'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                notificationService.sendTestContractNotification(isResign: true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                              ),
                              child: const Text('合同续签通知'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 面试通知测试
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('面试通知测试', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                notificationService.sendTestInterviewNotification(subType: 'arrange');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text('面试安排通知'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                notificationService.sendTestInterviewNotification(subType: 'result');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                              ),
                              child: const Text('面试结果通知'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 消息列表
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('当前通知数量: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Obx(() => Text(
                            '${notificationService.notifications.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          )),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              notificationService.clearAllNotifications();
                            },
                            child: const Text('清空'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() => notificationService.notifications.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('暂无通知'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: notificationService.notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notificationService.notifications[index];
                              return ListTile(
                                title: Text(notification.title),
                                subtitle: Text(notification.content),
                                trailing: Text(
                                  _formatTimestamp(notification.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 格式化时间戳
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}-${timestamp.day}';
    }
  }
} 
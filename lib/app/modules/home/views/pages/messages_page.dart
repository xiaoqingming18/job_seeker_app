import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../../../services/notification_service.dart';
import '../../../../models/notification_model.dart';
import '../../../../routes/app_pages.dart';

class MessagesPage extends GetView<HomeController> {
  const MessagesPage({Key? key}) : super(key: key);
  
  // 消息类型选择和页面控制
  static final RxInt _selectedTabIndex = 0.obs;
  static final PageController _pageController = PageController(initialPage: 0);
  
  @override
  Widget build(BuildContext context) {
    // 获取NotificationService实例
    final NotificationService notificationService = Get.find<NotificationService>();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(notificationService),
          Expanded(
            child: _buildMessagePageView(notificationService),
          ),
        ],
      ),
    );
  }
  
  // 构建页面头部
  Widget _buildHeader(NotificationService notificationService) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "消息中心",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Row(
                children: [
                  // 添加测试按钮 (仅在调试模式下显示)
                  IconButton(
                    icon: const Icon(Icons.add_alert, color: Color(0xFF666666)),
                    onPressed: () {
                      notificationService.sendTestContractNotification(isResign: false);
                      Get.snackbar('测试', '已添加合同签署通知');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // 搜索按钮
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF666666)),
                    onPressed: () {
                      Get.snackbar('提示', '搜索功能正在开发中...');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMessageTabs(),
        ],
      ),
    );
  }
  
  // 构建消息分类标签
  Widget _buildMessageTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab("全部消息", 0),
          _buildTab("系统通知", 1),
          _buildTab("项目消息", 2),
        ],
      ),
    );
  }
  
  // 构建单个标签
  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _selectedTabIndex.value = index;
          _pageController.jumpToPage(index);
        },
        child: Obx(() {
          final isActive = _selectedTabIndex.value == index;
          return Container(
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1976D2) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          );
        }),
      ),
    );
  }
  
  // 构建消息页面视图
  Widget _buildMessagePageView(NotificationService notificationService) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _selectedTabIndex.value = index;
      },
      children: [
        _buildMessageList('all', notificationService), // 全部消息
        _buildMessageList('system', notificationService), // 系统通知
        _buildMessageList('project', notificationService), // 项目消息
      ],
    );
  }
  
  // 构建消息列表
  Widget _buildMessageList(String filterType, NotificationService notificationService) {
    // 静态消息数据模型
    final List<Map<String, dynamic>> staticMessages = [
      {
        'type': 'system',
        'title': '账号安全提醒',
        'content': '您的账号于今日10:30在新设备上登录，如非本人操作，请及时修改密码。',
        'time': '10:30',
        'isRead': false,
        'avatar': Icons.security,
        'avatarBgColor': Colors.orange[100],
        'avatarColor': Colors.orange,
      },
      {
        'type': 'project',
        'title': '项目申请通过',
        'content': '恭喜您！您申请的"中建三局-高级砌筑工"岗位已通过初审，请等待进一步通知。',
        'time': '昨天',
        'isRead': true,
        'avatar': Icons.work,
        'avatarBgColor': Colors.green[100],
        'avatarColor': Colors.green,
      },
      // 保留其他静态消息...
    ];

    return Obx(() {
      // 合并静态消息和动态通知
      final List<dynamic> allMessages = [..._convertNotificationsToMessages(notificationService.notifications), ...staticMessages];
      
      // 根据选中的标签过滤消息
      final List<dynamic> filteredMessages;
      if (filterType == 'all') {
        filteredMessages = allMessages;
      } else if (filterType == 'system') {
        filteredMessages = allMessages.where((message) => 
          message['type'] == 'system' || message['type'] == NotificationType.system
          // 不再在系统通知中显示合同通知，除非用户明确要求
          // 合同通知应有自己独立的类别
        ).toList();
      } else if (filterType == 'project') {
        filteredMessages = allMessages.where((message) => 
          message['type'] == 'project' || 
          message['type'] == NotificationType.job ||
          message['type'] == NotificationType.contract // 合同通知归类到项目消息
        ).toList();
      } else {
        filteredMessages = allMessages.where((message) => message['type'] == filterType).toList();
      }

      if (filteredMessages.isEmpty) {
        return _buildEmptyState();
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ...filteredMessages.map((message) => _buildMessageItem(message)).toList(),
              // 底部留白
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }
  
  // 将通知转换为消息格式
  List<Map<String, dynamic>> _convertNotificationsToMessages(List<NotificationModel> notifications) {
    return notifications.map((notification) {
      // 根据通知类型设置不同的图标和颜色
      IconData icon;
      Color? bgColor;
      Color? iconColor;
      
      switch (notification.type) {
        case NotificationType.contract:
          final isResign = notification.data != null && notification.data!['type'] == 'reSign';
          icon = isResign ? Icons.autorenew : Icons.assignment;
          bgColor = isResign ? Colors.teal[100] : Colors.indigo[100];
          iconColor = isResign ? Colors.teal : Colors.indigo;
          break;
        case NotificationType.system:
          icon = Icons.announcement;
          bgColor = Colors.blue[100];
          iconColor = Colors.blue;
          break;
        case NotificationType.user:
          icon = Icons.person;
          bgColor = Colors.purple[100];
          iconColor = Colors.purple;
          break;
        case NotificationType.job:
          icon = Icons.work;
          bgColor = Colors.green[100];
          iconColor = Colors.green;
          break;
        default:
          icon = Icons.notifications;
          bgColor = Colors.grey[100];
          iconColor = Colors.grey[700];
      }
      
      // 格式化时间
      String timeStr = _formatNotificationTime(notification.timestamp);
      
      return {
        'type': notification.type,
        'title': notification.title,
        'content': notification.content,
        'time': timeStr,
        'isRead': false, // 默认为未读
        'avatar': icon,
        'avatarBgColor': bgColor,
        'avatarColor': iconColor,
        'data': notification.data,
        'isNotification': true, // 标记为来自通知服务的消息
      };
    }).toList();
  }
  
  // 格式化通知时间
  String _formatNotificationTime(DateTime timestamp) {
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
  
  // 构建消息项
  Widget _buildMessageItem(Map<String, dynamic> message) {
    // 处理通知特殊动作
    void handleMessageTap() {
      // 如果是合同通知，执行特殊处理
      if (message['type'] == NotificationType.contract && message['data'] != null) {
        final contractCode = message['data']['contractCode'] ?? '';
        final contractType = message['data']['type'] ?? '';
        final isResign = contractType == 'reSign';
        
        Get.snackbar(
          isResign ? '合同续签' : '合同签订', 
          '即将跳转到合同${isResign ? '续签' : '签署'}页面，合同编号：$contractCode',
          duration: const Duration(seconds: 2),
        );
        
        // 跳转到合同签署页面
        Get.toNamed(
          Routes.CONTRACT_SIGN,
          parameters: {'contractCode': contractCode},
        );
        return;
      }
      
      // 其他消息的默认处理
      Get.snackbar('提示', '消息详情功能正在开发中...');
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: handleMessageTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像或图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: message['avatarBgColor'],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    message['avatar'],
                    color: message['avatarColor'],
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 消息内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: message['isRead'] ? FontWeight.normal : FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message['content'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 如果是合同通知，显示操作按钮
                    if (message['type'] == NotificationType.contract) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: handleMessageTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1976D2),
                              minimumSize: const Size(80, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              side: const BorderSide(color: Color(0xFF1976D2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(message['data'] != null && message['data']['type'] == 'reSign' 
                                ? '去续签' 
                                : '去签署'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无消息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '您的消息将显示在这里',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

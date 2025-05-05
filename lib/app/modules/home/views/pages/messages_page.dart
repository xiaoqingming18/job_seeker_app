import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/im_controller.dart';
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
    
    // 获取或创建ImController实例
    final ImController imController = Get.find<ImController>();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(notificationService, imController),
          Expanded(
            child: _buildMessagePageView(notificationService, imController),
          ),
        ],
      ),
    );
  }
  
  // 构建页面头部
  Widget _buildHeader(NotificationService notificationService, ImController imController) {
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
              ),              Row(
                children: [
                  // 添加测试按钮 (仅在调试模式下显示)
                  PopupMenuButton(
                    icon: const Icon(Icons.add_alert, color: Color(0xFF666666)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'contract',
                        child: const Text('测试合同通知'),
                        onTap: () {
                          notificationService.sendTestContractNotification(isResign: false);
                          Get.snackbar('测试', '已添加合同签署通知');
                        },
                      ),
                      PopupMenuItem(
                        value: 'interview_arrange',
                        child: const Text('测试面试安排通知'),
                        onTap: () {
                          notificationService.sendTestInterviewNotification(subType: 'arrange');
                          Get.snackbar('测试', '已添加面试安排通知');
                        },
                      ),
                      PopupMenuItem(
                        value: 'interview_result',
                        child: const Text('测试面试结果通知'),
                        onTap: () {
                          notificationService.sendTestInterviewNotification(subType: 'result');
                          Get.snackbar('测试', '已添加面试结果通知');
                        },
                      ),
                      PopupMenuItem(
                        value: 'refresh_im',
                        child: const Text('刷新IM会话'),
                        onTap: () {
                          imController.loadConversations();
                          Get.snackbar('刷新', '正在刷新IM会话列表');
                        },
                      ),
                    ],
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
  Widget _buildMessagePageView(NotificationService notificationService, ImController imController) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _selectedTabIndex.value = index;
      },
      children: [
        _buildMessageList('all', notificationService, imController), // 全部消息
        _buildMessageList('system', notificationService, imController), // 系统通知
        _buildMessageList('project', notificationService, imController), // 项目消息
      ],
    );
  }
  
  // 构建消息列表
  Widget _buildMessageList(String filterType, NotificationService notificationService, ImController imController) {
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
        'timestamp': _getStaticMessageTimestamp(hours: 2), // 2小时前
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
        'timestamp': _getStaticMessageTimestamp(days: 1), // 1天前
      },
      // 保留其他静态消息...
    ];

    return Obx(() {
      // 获取IM会话列表
      List<Map<String, dynamic>> imConversations = imController.conversations;
      
      // 合并静态消息、动态通知和IM会话
      final List<dynamic> allMessages = [
        ...imConversations,
        ..._convertNotificationsToMessages(notificationService.notifications), 
        ...staticMessages
      ];
      
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
          message['type'] == NotificationType.contract || // 合同通知归类到项目消息
          message['type'] == NotificationType.interview || // 面试通知也归类到项目消息
          message['type'] == 'im_conversation' // IM会话归类到项目消息
        ).toList();
      } else {
        filteredMessages = allMessages.where((message) => message['type'] == filterType).toList();
      }
      
      // 确保所有消息都有时间戳
      _ensureAllMessagesHaveTimestamp(filteredMessages);
      
      // 对消息按时间戳进行排序（新消息在前）
      _sortMessagesByTime(filteredMessages);

      // 处理加载中状态
      if (filterType == 'project' && imController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('加载会话中...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        );
      }

      // 处理错误状态
      if (filterType == 'project' && imController.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                imController.errorMessage.value,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                onPressed: () => imController.loadConversations(),
              ),
            ],
          ),
        );
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
              ...filteredMessages.map((message) => _buildMessageItem(message, imController)).toList(),
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
        case NotificationType.interview:
          final subType = notification.data != null ? notification.data!['type'] : 'arrange';
          if (subType == 'result') {
            icon = Icons.fact_check;
            bgColor = Colors.amber[100];
            iconColor = Colors.amber[800];
          } else {
            icon = Icons.event_available;
            bgColor = Colors.orange[100];
            iconColor = Colors.orange[800];
          }
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
        'timestamp': notification.timestamp.millisecondsSinceEpoch, // 添加时间戳字段
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
  
  // 排序消息列表（按时间戳降序排列，最新的消息在前面）
  void _sortMessagesByTime(List<dynamic> messages) {
    messages.sort((a, b) {
      // 获取a的时间戳
      int aTimestamp;
      if (a['timestamp'] != null) {
        // 直接使用timestamp字段
        aTimestamp = a['timestamp'];
      } else if (a['type'] == 'im_conversation' && a['rawData'] != null && a['rawData']['lastTimestamp'] != null) {
        // 从IM会话数据中获取时间戳
        aTimestamp = a['rawData']['lastTimestamp'];
      } else {
        // 默认为当前时间减去一天（较旧的消息）
        aTimestamp = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      }
      
      // 获取b的时间戳
      int bTimestamp;
      if (b['timestamp'] != null) {
        bTimestamp = b['timestamp'];
      } else if (b['type'] == 'im_conversation' && b['rawData'] != null && b['rawData']['lastTimestamp'] != null) {
        bTimestamp = b['rawData']['lastTimestamp'];
      } else {
        bTimestamp = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      }
      
      // 降序排列，较新的时间戳（较大的值）排在前面
      return bTimestamp.compareTo(aTimestamp);
    });
  }
  
    // 构建消息项
  Widget _buildMessageItem(Map<String, dynamic> message, ImController imController) {
    // 处理消息点击事件
    void handleMessageTap() {
      if (message['type'] == 'im_conversation') {
        // 打开IM会话详情页
        imController.openConversation(message['id']);
      } else if (message['type'] == NotificationType.contract) {
        // 处理合同通知，跳转到合同签署页面
        final contractCode = message['data'] != null ? message['data']['contractCode'] : null;
        if (contractCode != null) {
        Get.toNamed(
          Routes.CONTRACT_SIGN,
            parameters: {'contractCode': contractCode}
        );
        } else {
          Get.snackbar('提示', '无效的合同编号');
      }
      } else if (message['type'] == NotificationType.interview) {
        // 处理面试通知
        Get.snackbar('提示', '面试详情页面正在开发中');
      } else {
        // 处理其他类型的消息
        Get.snackbar('提示', '该消息类型的详情页正在开发中');
      }
    }
    
    // 处理图标
    IconData avatarIcon;
    Color? avatarBgColor;
    Color? avatarColor;
        
    if (message['type'] == 'im_conversation') {
      // IM会话使用聊天图标
      avatarIcon = Icons.chat;
      avatarBgColor = Colors.teal[100];
      avatarColor = Colors.teal;
    } else if (message['avatar'] is IconData) {
      // 如果是直接的IconData
      avatarIcon = message['avatar'];
      avatarBgColor = message['avatarBgColor'];
      avatarColor = message['avatarColor'];
    } else if (message['avatar'] is String && message['avatar'].toString().startsWith('Icons.')) {
      // 如果是字符串表示的图标
      try {
        final iconName = message['avatar'].toString().replaceFirst('Icons.', '');
        avatarIcon = Icons.chat; // 默认为聊天图标
        // 解析颜色字符串
        avatarBgColor = _parseColor(message['avatarBgColor'] ?? 'teal.100');
        avatarColor = _parseColor(message['avatarColor'] ?? 'teal');
      } catch (e) {
        avatarIcon = Icons.error;
        avatarBgColor = Colors.red[100];
        avatarColor = Colors.red;
        }
    } else {
      // 默认图标
      avatarIcon = Icons.message;
      avatarBgColor = Colors.blue[100];
      avatarColor = Colors.blue;
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
                  color: avatarBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    avatarIcon,
                    color: avatarColor,
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
                    // 如果是IM会话，显示查看按钮
                    if (message['type'] == 'im_conversation') ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => imController.openConversation(message['id']),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1976D2),
                              minimumSize: const Size(80, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              side: const BorderSide(color: Color(0xFF1976D2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('查看会话'),
                          ),
                        ],
                      ),
                    ],
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
                    // 如果是面试通知，显示操作按钮
                    if (message['type'] == NotificationType.interview) ...[
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
                            child: Text(message['data'] != null && message['data']['type'] == 'result' 
                                ? '查看结果' 
                                : '查看详情'),
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
  
  /// 解析颜色字符串
  Color? _parseColor(String colorStr) {
    try {
      if (colorStr.contains('.')) {
        final parts = colorStr.split('.');
        final colorName = parts[0].toLowerCase();
        final shade = int.tryParse(parts[1]) ?? 500;
        
        // 尝试匹配颜色名称
        switch (colorName) {
          case 'red': return Colors.red[shade];
          case 'pink': return Colors.pink[shade];
          case 'purple': return Colors.purple[shade];
          case 'deepPurple': return Colors.deepPurple[shade];
          case 'indigo': return Colors.indigo[shade];
          case 'blue': return Colors.blue[shade];
          case 'lightBlue': return Colors.lightBlue[shade];
          case 'cyan': return Colors.cyan[shade];
          case 'teal': return Colors.teal[shade];
          case 'green': return Colors.green[shade];
          case 'lightGreen': return Colors.lightGreen[shade];
          case 'lime': return Colors.lime[shade];
          case 'yellow': return Colors.yellow[shade];
          case 'amber': return Colors.amber[shade];
          case 'orange': return Colors.orange[shade];
          case 'deepOrange': return Colors.deepOrange[shade];
          case 'brown': return Colors.brown[shade];
          case 'grey': return Colors.grey[shade];
          case 'blueGrey': return Colors.blueGrey[shade];
          default: return Colors.blue[shade];
        }
      } else {
        // 单独颜色名称
        switch (colorStr.toLowerCase()) {
          case 'red': return Colors.red;
          case 'pink': return Colors.pink;
          case 'purple': return Colors.purple;
          case 'deepPurple': return Colors.deepPurple;
          case 'indigo': return Colors.indigo;
          case 'blue': return Colors.blue;
          case 'lightBlue': return Colors.lightBlue;
          case 'cyan': return Colors.cyan;
          case 'teal': return Colors.teal;
          case 'green': return Colors.green;
          case 'lightGreen': return Colors.lightGreen;
          case 'lime': return Colors.lime;
          case 'yellow': return Colors.yellow;
          case 'amber': return Colors.amber;
          case 'orange': return Colors.orange;
          case 'deepOrange': return Colors.deepOrange;
          case 'brown': return Colors.brown;
          case 'grey': return Colors.grey;
          case 'blueGrey': return Colors.blueGrey;
          default: return Colors.blue;
        }
      }
    } catch (e) {
      return Colors.blue;
    }
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

  int _getStaticMessageTimestamp({int hours = 0, int days = 0}) {
    return DateTime.now().subtract(Duration(hours: hours, days: days)).millisecondsSinceEpoch;
  }

  void _ensureAllMessagesHaveTimestamp(List<dynamic> messages) {
    for (var message in messages) {
      if (message['timestamp'] == null) {
        message['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      }
    }
  }
}

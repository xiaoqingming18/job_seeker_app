import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class MessagesPage extends GetView<HomeController> {
  const MessagesPage({Key? key}) : super(key: key);
  
  // 消息类型选择和页面控制
  static final RxInt _selectedTabIndex = 0.obs;
  static final PageController _pageController = PageController(initialPage: 0);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildMessagePageView(),
          ),
        ],
      ),
    );
  }
  
  // 构建页面头部
  Widget _buildHeader() {
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
  Widget _buildMessagePageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _selectedTabIndex.value = index;
      },
      children: [
        _buildMessageList('all'), // 全部消息
        _buildMessageList('system'), // 系统通知
        _buildMessageList('project'), // 项目消息
      ],
    );
  }
  
  // 构建消息列表
  Widget _buildMessageList(String filterType) {
    // 消息数据模型
    final List<Map<String, dynamic>> allMessages = [
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
      {
        'type': 'system',
        'title': '实名认证成功',
        'content': '您的实名认证已成功通过审核，现在可以申请更多高薪项目了。',
        'time': '昨天',
        'isRead': true,
        'avatar': Icons.verified_user,
        'avatarBgColor': Colors.blue[100],
        'avatarColor': Colors.blue,
      },
      {
        'type': 'project',
        'title': '工资已发放',
        'content': '您在"恒大建筑集团-木工"项目的工资已发放，请查收。',
        'time': '3天前',
        'isRead': true,
        'avatar': Icons.payments,
        'avatarBgColor': Colors.purple[100],
        'avatarColor': Colors.purple,
      },
      {
        'type': 'system',
        'title': '新功能上线',
        'content': '工作日报功能已上线，现在可以更方便地记录每日工作内容和工时了。',
        'time': '4天前',
        'isRead': true,
        'avatar': Icons.new_releases,
        'avatarBgColor': Colors.red[100],
        'avatarColor': Colors.red,
      },
      {
        'type': 'project',
        'title': '项目即将开始',
        'content': '您申请的"华润建筑-钢筋工班组"项目将于3天后开始，请做好准备。',
        'time': '5天前',
        'isRead': true,
        'avatar': Icons.event,
        'avatarBgColor': Colors.teal[100],
        'avatarColor': Colors.teal,
      },
      {
        'type': 'system',
        'title': '证书到期提醒',
        'content': '您的"建筑施工特种作业人员证"将于30天后到期，请及时更新。',
        'time': '6天前',
        'isRead': true,
        'avatar': Icons.warning,
        'avatarBgColor': Colors.amber[100],
        'avatarColor': Colors.amber[700],
      },
    ];

    // 根据选中的标签过滤消息
    final List<Map<String, dynamic>> filteredMessages;
    if (filterType == 'all') {
      filteredMessages = allMessages;
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
  }
  
  // 构建消息项
  Widget _buildMessageItem(Map<String, dynamic> message) {
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
        onTap: () {
          Get.snackbar('提示', '消息详情功能正在开发中...');
        },
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
          Image.asset(
            'assets/images/empty_message.png',
            width: 120,
            height: 120,
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

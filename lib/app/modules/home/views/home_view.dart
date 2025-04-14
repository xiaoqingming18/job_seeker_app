import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'pages/projects_page.dart';
import 'pages/messages_page.dart';
import 'pages/profile_page.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 页面内容区域
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(), // 禁用滑动翻页
                // 移除onPageChanged以避免循环触发changePage
                children: const [
                  ProjectsPage(),
                  MessagesPage(),
                  ProfilePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      // 自定义底部导航栏 - 高保真实现
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        height: 65,
        child: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'assets/icons/project.png', 'assets/icons/project_active.png', '项目'),
            _buildNavItem(1, 'assets/icons/message.png', 'assets/icons/message_active.png', '消息'),
            _buildNavItem(2, 'assets/icons/profile.png', 'assets/icons/profile_active.png', '我的'),
          ],
        )),
      ),
    );
  }
  
  // 构建导航项
  Widget _buildNavItem(int index, String iconPath, String activeIconPath, String label) {
    final bool isSelected = controller.selectedIndex.value == index;
    
    // 暂时使用图标代替，后续可以替换为实际图片资源
    IconData iconData;
    IconData activeIconData;
    
    switch(index) {
      case 0:
        iconData = Icons.work_outline;
        activeIconData = Icons.work;
        break;
      case 1:
        iconData = Icons.message_outlined;
        activeIconData = Icons.message;
        break;
      case 2:
        iconData = Icons.person_outline;
        activeIconData = Icons.person;
        break;
      default:
        iconData = Icons.work_outline;
        activeIconData = Icons.work;
    }
    
    return InkWell(
      onTap: () => controller.changePage(index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIconData : iconData,
              size: 28,
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 根据索引获取页面标题
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return '求职项目';
      case 1:
        return '消息中心';
      case 2:
        return '个人中心';
      default:
        return '求职者应用';
    }
  }
}

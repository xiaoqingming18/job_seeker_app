import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'pages/projects_page.dart';
import 'pages/messages_page.dart';
import 'pages/profile_page.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {    return Scaffold(
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
      // 底部导航栏
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.selectedIndex.value,
        onDestinationSelected: controller.changePage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: '项目',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: '消息',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      )),
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

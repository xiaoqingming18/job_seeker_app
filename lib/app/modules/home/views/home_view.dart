import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        centerTitle: true,
        actions: [
          // 添加退出登录按钮到应用栏
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 显示确认对话框
              Get.dialog(
                AlertDialog(
                  title: const Text('退出登录'),
                  content: const Text('确定要退出登录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
            tooltip: '退出登录',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '欢迎使用求职招聘系统',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '您已成功登录',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            Obx(() => Text(
              'Count: ${controller.count}',
              style: const TextStyle(fontSize: 20),
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.increment,
              child: const Text('增加计数'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            // 添加退出登录按钮到主界面
            ElevatedButton(
              onPressed: controller.logout,
              child: const Text('退出登录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

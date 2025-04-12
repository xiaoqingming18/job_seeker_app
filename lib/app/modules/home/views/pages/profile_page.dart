import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class ProfilePage extends GetView<HomeController> {
  const ProfilePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '个人资料',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('账户信息'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.snackbar('提示', '账户信息功能正在开发中...');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('我的简历'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.snackbar('提示', '我的简历功能正在开发中...');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.snackbar('提示', '设置功能正在开发中...');
              },
            ),
            const Divider(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: controller.logout,
              child: const Text('退出登录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class ProfilePage extends GetView<HomeController> {
  const ProfilePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 不使用Scaffold，直接返回带有渐变背景的Stack
    // 因为父级HomeView已经提供了Scaffold
    return Stack(
      children: [
        // 底层渐变背景 - 根据提供的CSS样式
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.2, -1.0), // 稍微偏左上角开始
              end: Alignment(0.2, 1.0),     // 稍微偏右下角结束
              colors: [
                Color(0xFFD7FFFE), // 浅青色
                Color(0xFFFFEFF), // 浅白色
              ],
            ),
          ),
        ),
        
        // 内容层
        Column(
          children: [
            // 顶部操作栏
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // 使图标居右显示
                children: [
                  // 切换账号图标
                  IconButton(
                    icon: const Icon(Icons.switch_account, color: Colors.black87, size: 16),
                    tooltip: '切换账号',
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.snackbar('提示', '切换账号功能正在开发中...');
                    },
                  ),
                  // 设置图标
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black87, size: 16),
                    tooltip: '设置',
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.snackbar('提示', '设置功能正在开发中...');
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      // 用户信息栏（透明背景）
                      Card(
                        elevation: 0,
                        color: Colors.transparent,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: const Text(
                            '张三',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text('查看或编辑个人信息'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Get.snackbar('提示', '个人信息功能正在开发中...');
                          },
                        ),
                      ),
                        // 常用功能栏
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '常用功能',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // 功能卡片1：在线简历
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '在线简历功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.description_outlined,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('在线简历'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片2：附件简历
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '附件简历功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.attach_file,
                                          color: Colors.green,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('附件简历'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片3：求职意向
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '求职意向功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.work_outline,
                                          color: Colors.orange,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('求职意向'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),                      ),                      // 底部留白
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

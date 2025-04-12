import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/user_model.dart';
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
                children: [                  // 切换账号图标
                  IconButton(
                    icon: const Icon(Icons.switch_account, color: Colors.black87, size: 16),
                    tooltip: '切换账号',
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      // 显示确认对话框
                      Get.dialog(
                        AlertDialog(
                          title: const Text('切换账号'),
                          content: const Text('是否退出当前账号并登录新账号？'),
                          actions: [
                            // 取消按钮
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('取消'),
                            ),
                            // 确认按钮
                            TextButton(
                              onPressed: () {
                                Get.back(); // 关闭对话框
                                controller.logout(); // 调用控制器的登出方法
                              },
                              child: const Text('确认'),
                            ),
                          ],
                        ),
                      );
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户信息栏（透明背景）
                      Card(
                        elevation: 0,
                        color: Colors.transparent,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(() {
                          // 从控制器获取缓存的用户资料
                          final userProfile = controller.cachedUserProfile.value;
                          

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blue,
                              backgroundImage: userProfile?.avatar != null && userProfile!.avatar!.isNotEmpty
                                  ? NetworkImage(userProfile.avatar!)
                                  : null,
                              child: userProfile?.avatar == null || userProfile!.avatar!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(
                              userProfile?.realName ?? userProfile?.username ?? '未知用户',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(userProfile?.mobile ?? userProfile?.email ?? '查看或编辑个人信息'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Get.snackbar('用户资料', _formatUserProfile(userProfile),
                                duration: const Duration(seconds: 8),
                                snackPosition: SnackPosition.BOTTOM);
                            },
                          );
                        }),
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
  
  /// 格式化用户资料为易读的字符串
  String _formatUserProfile(UserModel? profile) {
    if (profile == null) {
      return '未能获取用户资料';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('---- 缓存的用户资料 ----');
    if (profile.userId != null) buffer.writeln('用户ID: ${profile.userId}');
    if (profile.username != null) buffer.writeln('用户名: ${profile.username}');
    if (profile.realName != null) buffer.writeln('真实姓名: ${profile.realName}');
    if (profile.mobile != null) buffer.writeln('手机: ${profile.mobile}');
    if (profile.email != null) buffer.writeln('邮箱: ${profile.email}');
    if (profile.gender != null) buffer.writeln('性别: ${profile.gender}');
    if (profile.birthday != null) buffer.writeln('生日: ${profile.birthday}');
    if (profile.role != null) buffer.writeln('角色: ${profile.role}');
    if (profile.jobStatus != null) buffer.writeln('求职状态: ${profile.jobStatus}');
    if (profile.expectPosition != null) buffer.writeln('期望职位: ${profile.expectPosition}');
    if (profile.workYears != null) buffer.writeln('工作年限: ${profile.workYears}年');
    if (profile.skill != null) buffer.writeln('技能: ${profile.skill}');
    
    return buffer.toString();
  }
}

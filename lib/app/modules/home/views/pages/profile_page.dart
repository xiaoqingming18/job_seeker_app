import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/user_model.dart';
import '../../../../routes/app_pages.dart';
import '../../controllers/home_controller.dart';

class ProfilePage extends GetView<HomeController> {
  const ProfilePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 添加一个onInit调用，确保每次页面可见时都重新获取用户资料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 刷新用户资料数据
      controller.refreshUserProfile();
    });
    
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
                  ),                  // 设置图标
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black87, size: 16),
                    tooltip: '设置',
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.toNamed(Routes.SETTINGS); // 跳转到设置页面
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
                              backgroundImage: _isValidImageUrl(userProfile?.avatar)
                                  ? NetworkImage(userProfile!.avatar!)
                                  : null,
                              child: !_isValidImageUrl(userProfile?.avatar)
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
                            onTap: () async {
                              // 导航到个人资料编辑页面，并等待页面关闭
                              await Get.toNamed(Routes.PROFILE_EDIT);
                              // 页面返回后刷新用户资料
                              controller.refreshUserProfile();
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
                        ),
                      ),
                      
                      // 求职管理功能卡片
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
                                '求职管理',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // 功能卡片1：我的申请
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.MY_APPLICATIONS);
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.assignment_outlined,
                                          color: Colors.indigo,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('我的申请'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片2：我的面试
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '我的面试功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.event_available,
                                          color: Colors.teal,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('我的面试'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片3：录用通知
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '录用通知功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.mark_email_read,
                                          color: Colors.amber,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('录用通知'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片4：工作日历
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '工作日历功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.purple,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('工作日历'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // 工作管理卡片
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
                                '工作管理',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // 功能卡片1：合同管理
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '合同管理功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.file_present,
                                          color: Colors.brown,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('合同管理'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片2：工资查询
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '工资查询功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.green,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('工资查询'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片3：工作评价
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '工作评价功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.stars,
                                          color: Colors.deepOrange,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('工作评价'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片4：考勤记录
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '考勤记录功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.fact_check,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('考勤记录'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // 支持与帮助卡片
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
                                '支持与帮助',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // 功能卡片1：在线客服
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '在线客服功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.support_agent,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('在线客服'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片2：意见反馈
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '意见反馈功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.feedback_outlined,
                                          color: Colors.orange,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('意见反馈'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片3：常见问题
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '常见问题功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.help_outline,
                                          color: Colors.teal,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('常见问题'),
                                      ],
                                    ),
                                  ),
                                  // 功能卡片4：关于我们
                                  GestureDetector(
                                    onTap: () {
                                      Get.snackbar('提示', '关于我们功能正在开发中...');
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.grey,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text('关于我们'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // 底部留白
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
  
  /// 检查URL是否为有效的图片URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    
    // 检查URL是否以http://或https://开头
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }
    
    // 添加更多验证逻辑如果需要
    
    return true;
  }
}

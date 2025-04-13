import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserSection(),
            const Divider(),
            _buildAccountSection(),
            const Divider(),
            _buildNotificationSection(),
            const Divider(),
            _buildPrivacySection(),
            const Divider(),
            _buildAppearanceSection(),
            const Divider(),
            _buildAboutSection(),
            const SizedBox(height: 80), // 底部留白
          ],
        ),
      ),
    );
  }
  // 用户信息区域
  Widget _buildUserSection() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.person,
          size: 36,
          color: Colors.white,
        ),
      ),
      title: const Text(
        '个人信息',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('点击编辑个人资料'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // 验证Token是否过期
        final isValid = await controller.verifyToken();
        if (isValid) {
          Get.toNamed(Routes.PROFILE_EDIT);
        }
      },
    );
  }

  // 账户与安全区域
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            '账户与安全',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),        ListTile(
          leading: const Icon(Icons.lock_outline, color: Colors.blue),
          title: const Text('修改密码'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            // 验证Token是否过期
            final isValid = await controller.verifyToken();
            if (isValid) {
              _showChangePasswordDialog();
            }
          },
        ),
        Obx(() => ListTile(
          leading: const Icon(Icons.phone_android_outlined, color: Colors.blue),
          title: Text(controller.phoneTitle.value),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            // 验证Token是否过期
            final isValid = await controller.verifyToken();
            if (isValid) {
              // TODO: 实现手机号绑定功能
              Get.snackbar('功能开发中', '${controller.phoneTitle.value}功能即将上线');
            }
          },
        )),
        ListTile(
          leading: const Icon(Icons.email_outlined, color: Colors.blue),
          title: const Text('修改邮箱'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            // 验证Token是否过期
            final isValid = await controller.verifyToken();
            if (isValid) {
              // TODO: 实现修改邮箱功能
              Get.snackbar('功能开发中', '修改邮箱功能即将上线');
            }
          },
        ),
      ],
    );
  }

  // 通知设置区域
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            '通知设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Obx(() => SwitchListTile(
          title: const Text('接收应用通知'),
          subtitle: const Text('开启后可接收应用推送的通知'),
          value: controller.notificationsEnabled.value,
          activeColor: Colors.blue,
          onChanged: controller.toggleNotifications,
        )),
        Obx(() => SwitchListTile(
          title: const Text('接收招聘信息'),
          subtitle: const Text('开启后可接收招聘相关推送'),
          value: controller.receiveJobInfo.value,
          activeColor: Colors.blue,
          onChanged: controller.toggleReceiveJobInfo,
        )),
      ],
    );
  }

  // 隐私设置区域
  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            '隐私设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Obx(() => SwitchListTile(
          title: const Text('简历可见性'),
          subtitle: const Text('开启后企业可主动查看您的简历'),
          value: controller.resumeVisibility.value,
          activeColor: Colors.blue,
          onChanged: controller.toggleResumeVisibility,
        )),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
          title: const Text('隐私政策'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 显示隐私政策
            Get.snackbar('功能开发中', '隐私政策页面即将上线');
          },
        ),
      ],
    );
  }

  // 外观设置区域
  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            '外观设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Obx(() => SwitchListTile(
          title: const Text('深色模式'),
          subtitle: const Text('切换应用到深色主题'),
          value: controller.darkModeEnabled.value,
          activeColor: Colors.blue,
          onChanged: controller.toggleDarkMode,
        )),
        ListTile(
          title: const Text('语言设置'),
          subtitle: Obx(() => Text(controller.selectedLanguage.value)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguagePickerDialog(),
        ),
      ],
    );
  }

  // 关于应用区域
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            '关于',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.blue),
          title: const Text('关于我们'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 显示关于页面
            Get.snackbar('功能开发中', '关于页面即将上线');
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline, color: Colors.blue),
          title: const Text('帮助与反馈'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 显示帮助页面
            Get.snackbar('功能开发中', '帮助页面即将上线');
          },
        ),
        ListTile(
          leading: const Icon(Icons.update, color: Colors.blue),
          title: const Text('检查更新'),
          subtitle: const Text('当前版本: 0.1.0'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 检查应用更新
            Get.snackbar('已是最新版本', '您已经在使用最新版本');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('退出登录'),
          onTap: () => controller.logout(),
        ),
      ],
    );
  }

  // 修改密码对话框
  void _showChangePasswordDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 300,
          child: Form(
            key: controller.passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '修改密码',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                  controller: controller.oldPasswordController,
                  obscureText: !controller.showOldPassword.value,
                  decoration: InputDecoration(
                    labelText: '当前密码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showOldPassword.value 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                      ),
                      onPressed: () => controller.showOldPassword.toggle(),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入当前密码';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                  controller: controller.newPasswordController,
                  obscureText: !controller.showNewPassword.value,
                  decoration: InputDecoration(
                    labelText: '新密码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showNewPassword.value 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                      ),
                      onPressed: () => controller.showNewPassword.toggle(),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入新密码';
                    }
                    if (value.length < 6) {
                      return '密码长度需至少6位';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.showConfirmPassword.value,
                  decoration: InputDecoration(
                    labelText: '确认新密码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showConfirmPassword.value 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                      ),
                      onPressed: () => controller.showConfirmPassword.toggle(),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认新密码';
                    }
                    if (value != controller.newPasswordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 16),
                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value 
                          ? null 
                          : controller.updatePassword,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('确认修改'),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 语言选择对话框
  void _showLanguagePickerDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '选择语言',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...controller.languages.map((language) => RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: controller.selectedLanguage.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.changeLanguage(value);
                    Get.back();
                  }
                },
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

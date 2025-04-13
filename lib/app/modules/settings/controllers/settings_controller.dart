import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_pages.dart';
import '../../../services/api/user_api_service.dart';

class SettingsController extends GetxController {
  final UserApiService _userApiService = UserApiService();
  
  // 表单控制器
  final passwordFormKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // 加载状态
  final RxBool isLoading = false.obs;
  
  // 是否显示密码
  final RxBool showOldPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  
  // 是否开启通知
  final RxBool notificationsEnabled = true.obs;
  
  // 是否开启简历可见性
  final RxBool resumeVisibility = true.obs;
  
  // 是否接收招聘信息
  final RxBool receiveJobInfo = true.obs;
  
  // 深色模式
  final RxBool darkModeEnabled = false.obs;
  
  // 语言选项
  final RxString selectedLanguage = "中文".obs;
  final List<String> languages = ["中文", "English"];

  @override
  void onInit() {
    super.onInit();
    _loadUserPreferences();
  }

  @override
  void onClose() {
    // 释放控制器资源
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  // 加载用户偏好设置
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
      resumeVisibility.value = prefs.getBool('resume_visibility') ?? true;
      receiveJobInfo.value = prefs.getBool('receive_job_info') ?? true;
      darkModeEnabled.value = prefs.getBool('dark_mode_enabled') ?? false;
      selectedLanguage.value = prefs.getString('selected_language') ?? "中文";
    } catch (e) {
      debugPrint('加载用户偏好设置失败: $e');
    }
  }
  
  // 保存用户偏好设置
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', notificationsEnabled.value);
      await prefs.setBool('resume_visibility', resumeVisibility.value);
      await prefs.setBool('receive_job_info', receiveJobInfo.value);
      await prefs.setBool('dark_mode_enabled', darkModeEnabled.value);
      await prefs.setString('selected_language', selectedLanguage.value);
    } catch (e) {
      debugPrint('保存用户偏好设置失败: $e');
    }
  }
  
  // 切换通知开关
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    _saveUserPreferences();
  }
  
  // 切换简历可见性
  void toggleResumeVisibility(bool value) {
    resumeVisibility.value = value;
    _saveUserPreferences();
  }
  
  // 切换招聘信息接收
  void toggleReceiveJobInfo(bool value) {
    receiveJobInfo.value = value;
    _saveUserPreferences();
  }
  
  // 切换深色模式
  void toggleDarkMode(bool value) {
    darkModeEnabled.value = value;
    _saveUserPreferences();
    // 这里可以添加实际切换应用主题的逻辑
    // TODO: 实现深色模式切换
  }
  
  // 切换语言
  void changeLanguage(String language) {
    selectedLanguage.value = language;
    _saveUserPreferences();
    // 这里可以添加实际切换应用语言的逻辑
    // TODO: 实现语言切换
  }
  
  // 修改密码
  Future<void> updatePassword() async {
    // 表单验证
    if (!passwordFormKey.currentState!.validate()) {
      return;
    }
    
    // 检查新密码和确认密码是否一致
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        '错误',
        '新密码与确认密码不一致',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final result = await _userApiService.updateJobseekerPassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      
      if (result.isSuccess) {
        Get.snackbar(
          '成功',
          '密码修改成功',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
        
        // 清除输入框
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        Get.snackbar(
          '错误',
          result.message ?? '修改密码失败',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '修改密码时出现错误: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // 退出登录
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('确认退出'),
        content: const Text('你确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _userApiService.logout();
                Get.offAllNamed(Routes.AUTH); // 退出登录后跳转到登录页
              } catch (e) {
                debugPrint('退出登录失败: $e');
                Get.back();
                Get.snackbar(
                  '错误',
                  '退出登录失败: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

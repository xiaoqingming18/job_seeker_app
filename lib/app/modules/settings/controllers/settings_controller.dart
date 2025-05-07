import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../../models/token_verification_model.dart';
import '../../../models/user_model.dart';
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
  
  // 用户信息
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  
  // 手机号状态
  final RxString phoneTitle = "绑定手机号".obs;
  
  // 是否显示密码
  final RxBool showOldPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  
  // 是否开启通知
  final RxBool isPushEnabled = true.obs;
  
  // 是否开启简历可见性
  final RxBool resumeVisibility = true.obs;
  
  // 是否接收招聘信息
  final RxBool receiveJobInfo = true.obs;
  
  // 深色模式
  final RxBool themeIsDark = false.obs;
  
  // 语言选项
  final RxString selectedLanguage = 'zh_CN'.obs;
  final List<String> languages = ["中文", "English"];
  
  // 是否自动播放视频
  final RxBool autoPlayVideo = true.obs;
  
  // 应用版本
  final RxString appVersion = "1.0.0".obs;
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('SettingsController初始化');
    
    // 加载用户设置
    _loadUserPreferences();
    
    // 获取应用版本
    _getAppVersion();
    
    // 检查手机绑定状态
    _checkPhoneBindingStatus();
  }

  @override
  void onClose() {
    // 释放控制器资源
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
    // 加载缓存的用户资料
  Future<void> _loadCachedUserProfile() async {
    try {
      final profile = await _userApiService.getCachedJobseekerProfile();
      if (profile != null) {
        userProfile.value = profile;
        
        // 根据是否有手机号来设置绑定/更换手机号的标题
        if (profile.mobile != null && profile.mobile!.isNotEmpty) {
          phoneTitle.value = "更换手机号";
        } else {
          phoneTitle.value = "绑定手机号";
        }
      }
    } catch (e) {
      debugPrint('加载缓存的用户资料失败: $e');
    }
  }
  
  /// 加载用户偏好设置
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      themeIsDark.value = prefs.getBool('theme_is_dark') ?? false;
      selectedLanguage.value = prefs.getString('selected_language') ?? 'zh_CN';
      receiveJobInfo.value = prefs.getBool('receive_job_info') ?? true;
      autoPlayVideo.value = prefs.getBool('auto_play_video') ?? true;
      isPushEnabled.value = prefs.getBool('notifications_enabled') ?? true;
      resumeVisibility.value = prefs.getBool('resume_visibility') ?? true;
    } catch (e) {
      debugPrint('加载用户偏好设置失败: $e');
    }
  }
  
  /// 保存用户偏好设置
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('theme_is_dark', themeIsDark.value);
      await prefs.setString('selected_language', selectedLanguage.value);
      await prefs.setBool('receive_job_info', receiveJobInfo.value);
      await prefs.setBool('auto_play_video', autoPlayVideo.value);
      await prefs.setBool('notifications_enabled', isPushEnabled.value);
      await prefs.setBool('resume_visibility', resumeVisibility.value);
    } catch (e) {
      debugPrint('保存用户偏好设置失败: $e');
    }
  }
  
  /// 获取应用版本
  Future<void> _getAppVersion() async {
    // 实际情况下，可以使用package_info_plus插件获取应用版本
    // 这里使用模拟数据
    appVersion.value = "1.0.0";
  }
  
  /// 检查手机绑定状态
  Future<void> _checkPhoneBindingStatus() async {
    try {
      // 实际情况下，可以从API获取用户手机绑定状态
      // 这里使用模拟数据
      final isBound = false; // 模拟未绑定手机
      
      if (isBound) {
        phoneTitle.value = "修改手机号";
      } else {
        phoneTitle.value = "绑定手机号";
      }
    } catch (e) {
      debugPrint('检查手机绑定状态失败: $e');
    }
  }
  
  /// 验证Token是否有效
  /// 返回true表示有效，false表示无效或过期
  Future<bool> verifyToken({bool showError = true}) async {
    try {
      isLoading.value = true;
      final response = await _userApiService.verifyToken();
      
      if (response.isSuccess && response.data != null && response.data!.valid) {
        // Token有效
        return true;
      } else {
        // Token无效或过期
        if (showError) {
          final message = response.message ?? "登录已过期，请重新登录";
          Get.snackbar(
            '提示',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            duration: const Duration(seconds: 2),
            onTap: (_) {
              _handleTokenExpired();
            },
          );
        }
        
        await _handleTokenExpired();
        return false;
      }
    } catch (e) {
      debugPrint('验证Token出错: $e');
      if (showError) {
        Get.snackbar(
          '错误',
          '验证登录状态失败，请重新登录',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
      
      await _handleTokenExpired();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 处理Token过期的情况
  Future<void> _handleTokenExpired() async {
    try {
      // 清除Token
      await _userApiService.logout();
      // 延迟一小段时间，让提示消息可以显示
      await Future.delayed(const Duration(milliseconds: 500));
      // 跳转到登录页
      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      debugPrint('处理Token过期出错: $e');
    }
  }
  
  // 切换通知开关
  void togglePushNotification(bool value) {
    isPushEnabled.value = value;
    _saveUserPreferences();
    
    // 根据需要可以在这里调用更多通知相关的逻辑
    
    // 显示提示
    Get.snackbar(
      '通知设置已更新',
      value ? '您已开启应用推送通知' : '您已关闭应用推送通知',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 切换简历可见性
  void toggleResumeVisibility(bool value) {
    resumeVisibility.value = value;
    _saveUserPreferences();
  }
  
  // 切换深色模式
  void toggleDarkMode(bool value) {
    themeIsDark.value = value;
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
  
  // 切换是否接收招聘信息
  void toggleReceiveJobInfo(bool value) {
    receiveJobInfo.value = value;
    _saveUserPreferences();
  }
  
  // 切换是否自动播放视频
  void toggleAutoPlayVideo(bool value) {
    autoPlayVideo.value = value;
    _saveUserPreferences();
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
        // 关闭修改密码对话框
        Get.back();
        
        // 显示成功消息
        Get.snackbar(
          '成功',
          '密码修改成功，请重新登录',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );
        
        // 等待一段时间让用户看到提示
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // 清除输入框
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        
        // 清除Token并跳转到登录页
        await _userApiService.logout();
        Get.offAllNamed(Routes.AUTH);
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
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // 显示加载指示器
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              try {
                // 调用退出登录API
                await _userApiService.logout();
                
                // 清除本地Token
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                
                // 关闭加载指示器
                Get.back();
                
                // 跳转到登录页
                Get.offAllNamed(Routes.AUTH);
              } catch (e) {
                // 关闭加载指示器
                Get.back();
                
                // 显示错误提示
                Get.snackbar(
                  '退出失败',
                  '请稍后重试',
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

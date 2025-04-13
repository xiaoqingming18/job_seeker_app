import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_pages.dart';
import '../../../services/api/user_api_service.dart';
import '../../../models/token_verification_model.dart';

/// 启动页控制器 - 验证token有效性并执行相应跳转
class SplashController extends GetxController {
  final UserApiService _userApiService = UserApiService();
  
  // 状态指示器
  final RxBool isLoading = true.obs;
  final RxString message = '正在验证登录信息...'.obs;
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('======= SplashController初始化 =======');
    
    // 验证token并决定跳转目标
    _verifyTokenAndNavigate();
    
    // 安全机制：无论如何，3秒后强制跳转到登录页
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('======= 安全超时机制触发 =======');
      // 如果还在splash页面，强制跳转
      if (Get.currentRoute == Routes.SPLASH && isLoading.value) {
        _showErrorAndNavigateToAuth('验证超时，请重新登录');
      }
    });
  }
  
  /// 验证token并决定跳转
  Future<void> _verifyTokenAndNavigate() async {
    try {
      debugPrint('======= 正在验证TOKEN有效性 =======');
      
      // 检查是否有token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        debugPrint('======= 本地无TOKEN，跳转到登录页 =======');
        // 延迟一下，让启动页显示足够时间
        await Future.delayed(const Duration(milliseconds: 800));
        _navigateToAuth();
        return;
      }
      
      debugPrint('======= 本地有TOKEN，开始验证 =======');
      
      // 调用验证token接口
      final apiResponse = await _userApiService.verifyToken();
      
      if (apiResponse.isSuccess && apiResponse.data != null && apiResponse.data!.valid) {
        debugPrint('======= TOKEN验证成功，角色: ${apiResponse.data!.role} =======');
        
        // 获取并缓存用户资料
        try {
          await _userApiService.fetchAndCacheJobseekerProfile();
          debugPrint('======= 获取用户资料成功 =======');
        } catch (e) {
          debugPrint('======= 获取用户资料失败: $e =======');
          // 即使获取资料失败，依然继续跳转到首页
        }
        
        debugPrint('======= 跳转到首页 =======');
        _navigateToHome();
      } else {
        // Token无效，显示错误消息并跳转到登录页
        final errorMsg = apiResponse.message ?? 'Token无效，请重新登录';
        debugPrint('======= TOKEN验证失败: $errorMsg =======');
        _showErrorAndNavigateToAuth(errorMsg);
      }
    } catch (e) {
      debugPrint('======= 验证过程出错: $e =======');
      _showErrorAndNavigateToAuth('登录信息验证失败，请重新登录');
    }
  }
    /// 显示错误消息并导航到登录页
  void _showErrorAndNavigateToAuth(String errorMessage) {
    isLoading.value = false;
    message.value = errorMessage;
    
    // 显示错误提示
    Get.snackbar(
      '登录信息已失效',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      duration: const Duration(seconds: 3),
    );
    
    // 短暂延迟后导航到登录页
    Future.delayed(const Duration(seconds: 1), () {
      _navigateToAuth();
    });
  }
  
  /// 导航到登录页
  void _navigateToAuth() {
    Get.offAllNamed(Routes.AUTH);
  }
  
  /// 导航到首页
  void _navigateToHome() {
    Get.offAllNamed(Routes.HOME);
  }
}


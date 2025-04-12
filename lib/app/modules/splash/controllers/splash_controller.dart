import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_pages.dart';

/// 极简的启动页控制器
class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint('======= SplashController初始化 =======');
    
    // 直接调用检查函数，不使用延迟
    _checkTokenSimple();
    
    // 添加安全机制：无论如何，2秒后强制跳转
    Future.delayed(const Duration(seconds: 2), () {
      debugPrint('======= 安全超时机制触发 =======');
      // 如果还在splash页面，强制跳转
      if (Get.currentRoute == Routes.SPLASH) {
        _navigateToAuth();
      }
    });
  }
    // 极简版Token检查
  Future<void> _checkTokenSimple() async {
    try {
      debugPrint('======= 正在检查本地TOKEN =======');
      
      // 直接检查SharedPreferences中是否有token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final hasToken = token != null && token.isNotEmpty;
      
      debugPrint('======= TOKEN检查结果: ${hasToken ? "有token" : "无token"} =======');
      
      // 根据结果直接导航
      if (hasToken) {
        debugPrint('======= 跳转到首页 =======');
        _navigateToHome();
      } else {
        debugPrint('======= 跳转到登录页 =======');
        _navigateToAuth();
      }
    } catch (e) {
      debugPrint('======= 发生错误: $e =======');
      debugPrint('======= 跳转到登录页 =======');
      _navigateToAuth();
    }
  }
  
  // 提取导航方法，使用完整方式导航
  void _navigateToAuth() {
    Get.offAllNamed(Routes.AUTH);
  }
  
  void _navigateToHome() {
    Get.offAllNamed(Routes.HOME);
  }
}


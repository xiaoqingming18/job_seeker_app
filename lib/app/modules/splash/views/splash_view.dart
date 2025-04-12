import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_pages.dart';

/// 启动页视图 - 直接在视图中处理跳转逻辑而不依赖控制器
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    print("启动页初始化");
    
    // 延迟一小段时间后检查token并导航
    Future.delayed(Duration.zero, () {
      _checkTokenAndNavigate();
    });

    // 安全机制：无论如何，都会在2秒后导航
    Future.delayed(const Duration(seconds: 2), () {
      print("安全机制触发");
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _navigateBasedOnDefaultLogic();
      }
    });
  }

  // 检查token并导航
  Future<void> _checkTokenAndNavigate() async {
    try {
      print("开始检查token");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final hasToken = token != null && token.isNotEmpty;
      
      print("Token检查结果: ${hasToken ? '有token' : '无token'}");
      if (token != null) {
        print("Token值: $token");
      }
      
      if (!mounted) return;
      
      if (hasToken) {
        print("导航到首页");
        Get.offAllNamed(Routes.HOME);
      } else {
        print("导航到登录页");
        Get.offAllNamed(Routes.AUTH);
      }
    } catch (e) {
      print("检查Token出错: $e");
      if (mounted) {
        print("错误后导航到登录页");
        Get.offAllNamed(Routes.AUTH);
      }
    }
  }
  
  // 默认导航逻辑
  void _navigateBasedOnDefaultLogic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.getString('auth_token') != null;
      
      if (hasToken) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.AUTH);
      }
    } catch (e) {
      Get.offAllNamed(Routes.AUTH);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用标志
            const Icon(
              Icons.work_outline,
              size: 120,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            // 应用名称
            const Text(
              '求职者应用',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 48),
            // 加载指示器
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            // 加载提示
            const Text(
              '正在验证登录信息...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

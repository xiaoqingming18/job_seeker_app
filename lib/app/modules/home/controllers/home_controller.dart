import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/api/http_client.dart';
import '../../../services/api/user_api_service.dart';

class HomeController extends GetxController {
  // API 服务
  final UserApiService _userApiService = UserApiService();
  final HttpClient _httpClient = HttpClient();
  
  // 当前选中的导航索引
  final selectedIndex = 0.obs;
  // 页面控制器
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    // 初始化页面控制器
    pageController = PageController(initialPage: selectedIndex.value);
  }

  @override
  void onReady() {
    super.onReady();
    // 页面加载完成后的逻辑
  }

  @override
  void onClose() {
    // 销毁页面控制器
    pageController.dispose();
    super.onClose();
  }
  
  /// 切换页面
  void changePage(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  /// 退出登录
  void logout() async {
    try {
      // 调用登出方法，清除 token
      await _userApiService.logout();
      
      // 跳转到登录页面
      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      Get.snackbar('错误', '退出登录失败：${e.toString()}');
    }
  }
}

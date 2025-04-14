import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/user_model.dart';
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
  
  // 缓存的用户资料
  final Rx<UserModel?> cachedUserProfile = Rx<UserModel?>(null);
  @override
  void onInit() {
    super.onInit();
    // 初始化页面控制器
    pageController = PageController(initialPage: selectedIndex.value);
    // 获取缓存的用户资料
    _loadCachedUserProfile();
  }

  @override
  void onReady() {
    super.onReady();
    // 页面加载完成后的逻辑
  }
  
  /// 加载缓存的用户资料
  Future<void> _loadCachedUserProfile() async {
    try {
      print('正在获取缓存的用户资料...');
      final userProfile = await _userApiService.getCachedJobseekerProfile();
      if (userProfile != null) {
        cachedUserProfile.value = userProfile;
        print('获取缓存的用户资料成功: ${userProfile.toJson()}');
      } else {
        print('缓存中没有用户资料，尝试从服务器获取...');
        // 如果缓存中没有用户资料，尝试从服务器获取
        final response = await _userApiService.fetchAndCacheJobseekerProfile();
        if (response.isSuccess && response.data != null) {
          cachedUserProfile.value = response.data;
          print('从服务器获取用户资料成功: ${response.data!.toJson()}');
        } else {
          print('从服务器获取用户资料失败: ${response.message}');
        }
      }
    } catch (e) {
      print('获取用户资料时发生错误: $e');
    }
  }
  
  /// 刷新用户资料
  Future<void> refreshUserProfile() async {
    try {
      print('正在刷新用户资料...');
      // 从服务器获取最新的用户资料
      final response = await _userApiService.fetchAndCacheJobseekerProfile();
      if (response.isSuccess && response.data != null) {
        // 更新缓存的用户资料
        cachedUserProfile.value = response.data;
        print('刷新用户资料成功: ${response.data!.toJson()}');
      } else {
        print('刷新用户资料失败: ${response.message}');
        // 如果从服务器获取失败，尝试从缓存获取
        final cachedProfile = await _userApiService.getCachedJobseekerProfile();
        if (cachedProfile != null) {
          cachedUserProfile.value = cachedProfile;
        }
      }
    } catch (e) {
      print('刷新用户资料时发生错误: $e');
    }
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

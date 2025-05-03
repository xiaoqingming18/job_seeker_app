import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/user_model.dart';
import '../../../models/labor_demand_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/api/http_client.dart';
import '../../../services/api/user_api_service.dart';
import '../../../services/api/labor_demand_api_service.dart';
import './im_controller.dart';

class HomeController extends GetxController {
  // API 服务
  final UserApiService _userApiService = UserApiService();
  final LaborDemandApiService _laborDemandApiService = LaborDemandApiService();
  final HttpClient _httpClient = HttpClient();
  
  // 当前选中的导航索引
  final RxInt selectedIndex = 0.obs;
  // 页面控制器
  late PageController pageController;
  
  // 缓存的用户资料
  final Rx<UserModel?> cachedUserProfile = Rx<UserModel?>(null);

  // 劳务需求列表数据
  final laborDemands = <LaborDemandModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // 初始化页面控制器
    pageController = PageController(initialPage: selectedIndex.value);
    
    // 确保ImController被注册
    if (!Get.isRegistered<ImController>()) {
      Get.put(ImController());
    }
    
    // 获取缓存的用户资料
    _loadCachedUserProfile();
    // 加载劳务需求列表
    fetchLaborDemands();
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

  /// 获取劳务需求列表
  Future<void> fetchLaborDemands({int page = 1, int size = 10}) async {
    try {
      // 设置加载状态
      isLoading.value = true;
      hasError.value = false;
      
      // 构建查询条件
      final query = LaborDemandQuery(
        pageNum: page,
        pageSize: size,
        // 可以添加更多查询条件
        status: 'open',
      );
      
      // 发送请求获取劳务需求列表
      final response = await _laborDemandApiService.getLaborDemandList(query: query);
      
      // 处理响应结果
      if (response.isSuccess && response.data != null) {
        final pageData = response.data!;
        // 更新数据
        laborDemands.value = pageData.records;
        currentPage.value = pageData.current;
        totalPages.value = pageData.pages;
        totalItems.value = pageData.total;
        print('获取劳务需求列表成功: ${pageData.records.length}条数据');
      } else {
        // 设置错误状态
        hasError.value = true;
        errorMessage.value = response.message;
        print('获取劳务需求列表失败: ${response.message}');
      }
    } catch (e) {
      // 设置错误状态
      hasError.value = true;
      errorMessage.value = e.toString();
      print('获取劳务需求列表时发生错误: $e');
    } finally {
      // 结束加载状态
      isLoading.value = false;
    }
  }
  
  /// 刷新劳务需求列表
  Future<void> refreshLaborDemands() async {
    // 重置页码并获取最新数据
    await fetchLaborDemands(page: 1);
  }
  
  /// 加载更多劳务需求
  Future<void> loadMoreLaborDemands() async {
    // 如果当前页小于总页数，则加载下一页
    if (currentPage.value < totalPages.value) {
      await fetchLaborDemands(page: currentPage.value + 1);
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

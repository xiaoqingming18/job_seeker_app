import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/job_application_list_model.dart';
import '../../../services/api/job_application_api_service.dart';

class MyApplicationsController extends GetxController {
  final JobApplicationApiService _jobApplicationApiService = JobApplicationApiService();
  
  // 申请列表数据
  final applications = <JobApplicationItem>[].obs;
  
  // 页面控制变量
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  final pageSize = 10.obs;
  
  // 下拉刷新控制器
  late RefreshController refreshController;
  
  // 当前筛选状态
  final selectedStatus = Rx<String?>(null);
  final statusOptions = [
    {'value': null, 'label': '全部'},
    {'value': 'applied', 'label': '已申请'},
    {'value': 'processing', 'label': '处理中'},
    {'value': 'interview', 'label': '面试中'},
    {'value': 'accepted', 'label': '已录用'},
    {'value': 'rejected', 'label': '已拒绝'},
    {'value': 'cancelled', 'label': '已取消'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    // 初始化下拉刷新控制器
    refreshController = RefreshController();
    // 加载申请列表
    fetchApplications();
  }
  
  @override
  void onClose() {
    // 释放资源
    refreshController.dispose();
    super.onClose();
  }
  
  /// 获取申请列表
  Future<void> fetchApplications({int page = 1}) async {
    try {
      // 设置加载状态
      if (page == 1) {
        isLoading.value = true;
      }
      hasError.value = false;
      
      // 发送请求获取申请列表
      final response = await _jobApplicationApiService.getMyApplications(
        page: page, 
        size: pageSize.value,
        status: selectedStatus.value
      );
      
      // 处理响应
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        // 设置数据
        if (page == 1) {
          // 第一页，直接替换列表
          applications.value = data.list;
        } else {
          // 不是第一页，追加到列表末尾
          applications.addAll(data.list);
        }
        
        // 更新分页信息
        currentPage.value = data.pageNum;
        totalPages.value = data.totalPages;
        totalItems.value = data.total;
        pageSize.value = data.pageSize;
        
        print('获取申请列表成功: ${data.list.length}条记录');
      } else {
        // 设置错误状态
        hasError.value = true;
        errorMessage.value = response.message;
        print('获取申请列表失败: ${response.message}');
      }
    } catch (e) {
      // 设置错误状态
      hasError.value = true;
      errorMessage.value = e.toString();
      print('获取申请列表时发生错误: $e');
    } finally {
      // 结束加载状态
      isLoading.value = false;
      
      // 更新刷新控制器状态
      if (page == 1) {
        refreshController.refreshCompleted();
      } else {
        if (currentPage.value >= totalPages.value) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }
      }
    }
  }
  
  /// 刷新列表
  Future<void> onRefresh() async {
    await fetchApplications(page: 1);
  }
  
  /// 加载更多
  Future<void> onLoadMore() async {
    if (currentPage.value < totalPages.value) {
      await fetchApplications(page: currentPage.value + 1);
    } else {
      refreshController.loadNoData();
    }
  }
  
  /// 更改筛选状态
  void changeStatus(String? status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      fetchApplications(page: 1);
    }
  }
  
  /// 查看申请详情
  void viewApplicationDetail(int applicationId) {
    // 跳转到申请详情页面
    // Get.toNamed(Routes.APPLICATION_DETAIL, arguments: {'id': applicationId});
    Get.snackbar('提示', '申请详情功能正在开发中...');
  }
}

/// 下拉刷新控制器
class RefreshController {
  // 简化版的下拉刷新控制器，仅提供必要的方法
  
  void refreshCompleted() {
    // 刷新完成的回调
  }
  
  void loadComplete() {
    // 加载更多完成的回调
  }
  
  void loadNoData() {
    // 没有更多数据的回调
  }
  
  void dispose() {
    // 释放资源
  }
} 
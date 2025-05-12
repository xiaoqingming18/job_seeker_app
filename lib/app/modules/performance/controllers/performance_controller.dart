import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/performance_model.dart';
import 'package:job_seeker_app/app/models/project_member_model.dart';
import 'package:job_seeker_app/app/services/api/performance_api_service.dart';
import 'package:job_seeker_app/app/services/api/project_member_api_service.dart';
import 'package:job_seeker_app/app/services/api/user_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceController extends GetxController {
  final PerformanceApiService _performanceApiService = PerformanceApiService();
  final ProjectMemberApiService _projectMemberApiService = ProjectMemberApiService();
  
  // 加载状态
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // 绩效评估列表数据
  final performanceList = <PerformanceModel>[].obs;
  final currentPage = 1.obs;
  final totalItems = 0.obs;
  final pageSize = 10.obs;
  
  // 用户项目数据
  final userProjects = <ProjectMemberModel>[].obs;
  final selectedProjectId = RxnInt(null);
  
  // 绩效评估详情
  final selectedPerformance = Rxn<PerformanceModel>(null);
  
  // 筛选状态
  final selectedPeriod = RxString('');
  final TextEditingController periodController = TextEditingController();
  
  // 用户ID
  final userId = RxnInt(null);
  
  // 详情页评分颜色映射
  Color getScoreColor(int score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
  
  @override
  void onInit() {
    super.onInit();
    // 确保SharedPreferences被注册到GetX中
    SharedPreferences.getInstance().then((prefs) {
      if (!Get.isRegistered<SharedPreferences>()) {
        Get.put(prefs);
      }
    });
    // 初始化时获取用户ID
    initUserId();
    // 初始化时加载数据
    loadUserProjects();
  }
  
  @override
  void onClose() {
    // 释放资源
    periodController.dispose();
    super.onClose();
  }
  
  /// 初始化用户ID
  Future<void> initUserId() async {
    try {
      // 尝试从SharedPreferences中获取用户ID
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');
      
      if (storedUserId != null) {
        userId.value = storedUserId;
        print('从SharedPreferences获取到用户ID: $storedUserId');
        return;
      }
      
      // 如果获取不到userId，尝试获取用户资料
      print('尝试从用户资料中获取ID');
      final UserApiService userApiService = UserApiService();
      final response = await userApiService.getJobseekerProfile();
      
      if (response.isSuccess && response.data != null) {
        // 首先尝试从UserModel对象中获取userId
        int? id = response.data!.userId;
        
        // 如果userId为空，则尝试从原始JSON响应中获取id字段
        if (id == null) {
          final rawData = response.data!.toJson();
          if (rawData.containsKey('id')) {
            id = rawData['id'] as int;
            print('从原始API响应中获取到id字段: $id');
          } else {
            print('警告: API响应中既没有userId也没有id字段');
            // 输出原始数据以便调试
            print('API响应内容: $rawData');
          }
        }
        
        if (id != null) {
          userId.value = id;
          // 保存到SharedPreferences中以便后续使用
          await prefs.setInt('user_id', id);
          print('成功设置用户ID: $id');
        } else {
          print('警告: 无法从用户资料中获取有效的ID');
        }
      } else {
        print('获取用户资料失败: ${response.message}');
      }
    } catch (e) {
      print('初始化用户ID错误: $e');
    }
  }
  
  /// 获取当前用户ID
  int? getUserId() {
    return userId.value;
  }
  
  /// 加载用户参与的项目列表
  Future<void> loadUserProjects() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // 获取用户ID
      final currentUserId = getUserId();
      if (currentUserId == null) {
        print('等待用户ID初始化...');
        // 如果用户ID还未初始化完成，等待初始化完成后再尝试
        await Future.delayed(const Duration(seconds: 2));
        final retryUserId = getUserId();
        if (retryUserId == null) {
          hasError.value = true;
          errorMessage.value = '获取用户信息失败，请重新登录';
          return;
        }
      }
      
      final response = await _projectMemberApiService.getUserProjects(currentUserId ?? getUserId()!);
      
      if (response.isSuccess && response.data != null) {
        userProjects.assignAll(response.data!);
        
        // 如果有项目，默认选中第一个
        if (userProjects.isNotEmpty && selectedProjectId.value == null) {
          selectedProjectId.value = userProjects.first.projectId;
          // 加载绩效评估记录
          loadPerformanceList();
        }
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 加载绩效评估列表
  Future<void> loadPerformanceList({int page = 1}) async {
    if (selectedProjectId.value == null) return;
    
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final query = PerformanceQueryParams(
        projectId: selectedProjectId.value,
        evaluationPeriod: selectedPeriod.value.isNotEmpty ? selectedPeriod.value : null,
        pageNum: page,
        pageSize: pageSize.value,
      );
      
      final response = await _performanceApiService.getPerformancePage(query);
      
      if (response.isSuccess && response.data != null) {
        performanceList.assignAll(response.data!.list);
        currentPage.value = response.data!.pageNum;
        totalItems.value = response.data!.total;
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 获取绩效评估详情
  Future<void> loadPerformanceDetail(int id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final response = await _performanceApiService.getPerformanceInfo(id);
      
      if (response.isSuccess && response.data != null) {
        selectedPerformance.value = response.data;
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 切换项目
  void changeProject(int? projectId) {
    if (projectId != selectedProjectId.value) {
      selectedProjectId.value = projectId;
      // 重置页码
      currentPage.value = 1;
      // 加载新项目的评估记录
      loadPerformanceList();
    }
  }
  
  /// 设置评估周期筛选
  void setPeriodFilter(String period) {
    if (period != selectedPeriod.value) {
      selectedPeriod.value = period;
      periodController.text = period;
      // 重置页码
      currentPage.value = 1;
      // 重新加载数据
      loadPerformanceList();
    }
  }
  
  /// 清除评估周期筛选
  void clearPeriodFilter() {
    selectedPeriod.value = '';
    periodController.clear();
    // 重置页码
    currentPage.value = 1;
    // 重新加载数据
    loadPerformanceList();
  }
  
  /// 分页导航
  void goToPage(int page) {
    if (page != currentPage.value) {
      loadPerformanceList(page: page);
    }
  }
  
  /// 格式化日期显示
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  /// 格式化日期显示（短格式）
  String formatShortDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MM-dd HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  /// 获取总分的颜色
  Color getTotalScoreColor(double score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
  
  /// 获取得分评级文本
  String getScoreRating(double score) {
    if (score >= 9) return '优秀';
    if (score >= 7) return '良好';
    if (score >= 5) return '合格';
    return '需改进';
  }
} 
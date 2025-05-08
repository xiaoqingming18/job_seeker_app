import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/attendance_model.dart';
import 'package:job_seeker_app/app/models/attendance_statistics_model.dart';
import 'package:job_seeker_app/app/models/project_member_model.dart';
import 'package:job_seeker_app/app/services/api/attendance_api_service.dart';
import 'package:job_seeker_app/app/services/api/project_member_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_seeker_app/app/services/api/user_api_service.dart';

class AttendanceController extends GetxController with StateMixin<List<AttendanceModel>> {
  final AttendanceApiService _attendanceApiService = AttendanceApiService();
  final ProjectMemberApiService _projectMemberApiService = ProjectMemberApiService();
  
  // 考勤记录列表
  final RxList<AttendanceModel> attendanceRecords = <AttendanceModel>[].obs;
  
  // 考勤统计数据
  final Rx<AttendanceStatisticsModel?> statistics = Rx<AttendanceStatisticsModel?>(null);
  
  // 分页参数
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final int pageSize = 10;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isProjectsLoading = false.obs;
  
  // 筛选参数
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<int?> selectedProjectId = Rx<int?>(null);
  final RxString selectedStatus = ''.obs;
  
  // 今日考勤状态
  final RxBool hasCheckedInToday = false.obs;
  final RxBool hasCheckedOutToday = false.obs;
  
  // 用户ID
  late final RxInt userId = 0.obs;
  
  // 项目列表 (从API获取)
  final RxList<ProjectMemberModel> projects = <ProjectMemberModel>[].obs;
  
  // 状态列表
  final List<Map<String, dynamic>> statusList = [
    {'code': '', 'name': '全部'},
    {'code': 'normal', 'name': '正常'},
    {'code': 'late', 'name': '迟到'},
    {'code': 'early_leave', 'name': '早退'},
    {'code': 'absent', 'name': '缺勤'},
    {'code': 'leave', 'name': '请假'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    
    // 初始化日期范围为当月
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, 1);
    endDate.value = now;
    
    // 获取用户ID
    _getUserId().then((_) {
      // 加载用户参与的项目列表
      loadUserProjects();
      
      // 加载考勤记录
      loadAttendanceRecords();
      
      // 加载考勤统计
      loadAttendanceStatistics();
      
      // 检查今日是否已签到/签退
      checkTodayAttendanceStatus();
    });
  }
  
  @override
  void onReady() {
    super.onReady();
    // 页面准备好后刷新用户资料
    _refreshUserProfile();
  }
  
  @override
  void onClose() {
    super.onClose();
  }
  
  // 获取用户ID
  Future<void> _getUserId() async {
    try {
      print('开始获取用户ID...');
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      print('从SharedPreferences获取到的用户ID: $id');
      
      if (id != null && id > 0) {
        userId.value = id;
        print('设置用户ID为: $id');
        return; // 找到有效ID，直接返回
      }
      
      print('SharedPreferences中没有有效的用户ID，尝试从缓存的用户资料中获取...');
      // 尝试从用户资料中获取
      final userApiService = Get.find<UserApiService>();
      final userProfile = await userApiService.getCachedJobseekerProfile();
      
      if (userProfile != null) {
        print('从缓存中找到用户资料: ${userProfile.username}');
        
        if (userProfile.userId != null && userProfile.userId! > 0) {
          // 如果从缓存中找到了用户资料并含有ID，保存它
          userId.value = userProfile.userId!;
          print('从缓存的用户资料中获取到用户ID: ${userProfile.userId}');
          
          // 同时更新SharedPreferences
          await prefs.setInt('user_id', userProfile.userId!);
          print('已将用户ID保存到SharedPreferences');
          return; // 找到有效ID，直接返回
        } else {
          print('警告: 缓存的用户资料中没有有效的用户ID');
        }
      } else {
        print('没有找到缓存的用户资料');
      }
      
      print('尝试从服务器获取最新的用户资料...');
      // 尝试重新获取用户资料
      final profileResponse = await userApiService.fetchAndCacheJobseekerProfile();
      print('从服务器获取用户资料结果: ${profileResponse.isSuccess ? '成功' : '失败'} - ${profileResponse.message}');
      
      if (profileResponse.isSuccess && profileResponse.data != null) {
        print('服务器返回的用户资料: ${profileResponse.data!.username}, ID: ${profileResponse.data!.userId}');
        
        if (profileResponse.data!.userId != null && profileResponse.data!.userId! > 0) {
          // 保存找到的用户ID
          userId.value = profileResponse.data!.userId!;
          print('成功设置用户ID为: ${profileResponse.data!.userId}');
          
          // 更新SharedPreferences
          await prefs.setInt('user_id', profileResponse.data!.userId!);
          print('已将用户ID保存到SharedPreferences');
        } else {
          print('警告: 服务器返回的用户资料中没有有效的userId字段');
          _showLoginRequiredMessage();
        }
      } else {
        print('从服务器获取用户资料失败，无法获取用户ID');
        _showLoginRequiredMessage();
      }
    } catch (e) {
      print('获取用户ID过程中发生错误: ${e.toString()}');
      _showLoginRequiredMessage();
    }
  }
  
  // 显示需要登录的提示
  void _showLoginRequiredMessage() {
    Get.snackbar(
      '用户信息获取失败',
      '无法获取您的用户信息，请尝试重新登录',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: () {
          Get.toNamed('/auth'); // 导航到登录页面
        },
        child: const Text('去登录', style: TextStyle(color: Colors.white)),
      ),
    );
  }
  
  // 加载用户参与的项目列表
  Future<void> loadUserProjects() async {
    try {
      if (userId.value <= 0) {
        return;
      }
      
      isProjectsLoading.value = true;
      
      final response = await _projectMemberApiService.getUserProjects(userId.value);
      
      if (response.isSuccess && response.data != null) {
        // 清空现有项目列表
        projects.clear();
        
        // 更新项目列表
        projects.addAll(response.data!);
        
        // 如果没有选择项目，并且有项目可选，则默认选择第一个项目
        if (selectedProjectId.value == null && projects.isNotEmpty) {
          selectedProjectId.value = projects[0].projectId;
        }
      } else {
        Get.snackbar(
          '错误',
          '加载项目列表失败: ${response.message}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载项目列表失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProjectsLoading.value = false;
    }
  }
  
  // 加载考勤记录
  Future<void> loadAttendanceRecords({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
      } else if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isMoreLoading.value = true;
      }
      
      change(null, status: RxStatus.loading());
      
      final response = await _attendanceApiService.getMyAttendanceRecords(
        projectId: selectedProjectId.value,
        status: selectedStatus.value,
        startDate: startDate.value,
        endDate: endDate.value,
        page: currentPage.value,
        size: pageSize,
      );
      
      if (response.isSuccess) {
        final data = response.data;
        if (data != null) {
          // 安全地访问data中的records
          final List<AttendanceModel> records = [];
          
          if (data.containsKey('records') && data['records'] != null) {
            records.addAll(data['records'] as List<AttendanceModel>);
          }
          
          if (currentPage.value == 1) {
            attendanceRecords.clear();
          }
          
          attendanceRecords.addAll(records);
          totalItems.value = data['total'] ?? 0;
          totalPages.value = data['pages'] ?? 1;
          
          if (attendanceRecords.isEmpty) {
            change([], status: RxStatus.empty());
          } else {
            change(attendanceRecords.toList(), status: RxStatus.success());
          }
        }
      } else {
        change(null, status: RxStatus.error(response.message));
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
      isRefreshing.value = false;
    }
  }
  
  // 加载更多记录
  Future<void> loadMoreRecords() async {
    if (!isMoreLoading.value && currentPage.value < totalPages.value) {
      currentPage.value++;
      await loadAttendanceRecords();
    }
  }
  
  // 刷新记录
  Future<void> refreshRecords() async {
    await loadAttendanceRecords(isRefresh: true);
    await checkTodayAttendanceStatus();
  }
  
  // 加载考勤统计
  Future<void> loadAttendanceStatistics() async {
    try {
      final response = await _attendanceApiService.getMyAttendanceStatistics(
        startDate: startDate.value,
        endDate: endDate.value,
        projectId: selectedProjectId?.value,
      );
      
      if (response.isSuccess && response.data != null) {
        statistics.value = response.data;
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载考勤统计失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // 检查今日是否已签到/签退
  Future<void> checkTodayAttendanceStatus() async {
    try {
      // 设置为今天日期
      final today = DateTime.now();
      
      final response = await _attendanceApiService.getMyAttendanceRecords(
        startDate: today,
        endDate: today,
        page: 1,
        size: 10,
      );
      
      if (response.isSuccess && response.data != null) {
        // 安全地访问data中的records
        final data = response.data;
        final List<AttendanceModel> records = [];
        
        if (data != null && data.containsKey('records') && data['records'] != null) {
          records.addAll(data['records'] as List<AttendanceModel>);
        }
        
        if (records.isNotEmpty) {
          hasCheckedInToday.value = true;
          hasCheckedOutToday.value = records[0].checkOutTime != null;
        } else {
          hasCheckedInToday.value = false;
          hasCheckedOutToday.value = false;
        }
      }
    } catch (e) {
      print('检查今日考勤状态失败: ${e.toString()}');
    }
  }
  
  // 签到
  Future<void> checkIn({
    required int projectId,
    String? location,
    String? remarks,
  }) async {
    try {
      final response = await _attendanceApiService.checkIn(
        projectId: projectId,
        location: location,
        remarks: remarks,
      );
      
      if (response.isSuccess) {
        Get.snackbar(
          '成功',
          '签到成功',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        
        // 更新状态
        hasCheckedInToday.value = true;
        
        // 刷新数据
        refreshRecords();
        loadAttendanceStatistics();
      } else {
        Get.snackbar(
          '错误',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '签到失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  // 签退
  Future<void> checkOut({
    required int projectId,
    String? location,
    String? remarks,
  }) async {
    try {
      final response = await _attendanceApiService.checkOut(
        projectId: projectId,
        location: location,
        remarks: remarks,
      );
      
      if (response.isSuccess) {
        Get.snackbar(
          '成功',
          '签退成功',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        
        // 更新状态
        hasCheckedOutToday.value = true;
        
        // 刷新数据
        refreshRecords();
        loadAttendanceStatistics();
      } else {
        Get.snackbar(
          '错误',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '签退失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  // 更新筛选参数
  void updateFilter({
    DateTime? newStartDate,
    DateTime? newEndDate,
    int? projectId,
    String? status,
  }) {
    bool hasChanged = false;
    
    if (newStartDate != null && newStartDate != startDate.value) {
      startDate.value = newStartDate;
      hasChanged = true;
    }
    
    if (newEndDate != null && newEndDate != endDate.value) {
      endDate.value = newEndDate;
      hasChanged = true;
    }
    
    if (projectId != selectedProjectId.value) {
      selectedProjectId.value = projectId;
      hasChanged = true;
    }
    
    if (status != null && status != selectedStatus.value) {
      selectedStatus.value = status;
      hasChanged = true;
    }
    
    if (hasChanged) {
      currentPage.value = 1;
      loadAttendanceRecords();
      loadAttendanceStatistics();
    }
  }
  
  // 格式化日期
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // 格式化时间
  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('HH:mm').format(time);
  }
  
  // 获取状态颜色
  Color getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'early_leave':
        return Colors.amber;
      case 'absent':
        return Colors.red;
      case 'leave':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  // 刷新用户资料
  Future<void> _refreshUserProfile() async {
    try {
      final userApiService = Get.find<UserApiService>();
      final profileResponse = await userApiService.fetchAndCacheJobseekerProfile();
      
      if (profileResponse.isSuccess && profileResponse.data != null && 
          profileResponse.data!.userId != null && profileResponse.data!.userId! > 0) {
        // 更新用户ID
        userId.value = profileResponse.data!.userId!;
        
        // 如果项目列表为空，尝试重新加载
        if (projects.isEmpty) {
          loadUserProjects();
        }
      }
    } catch (e) {
      print('刷新用户资料失败: ${e.toString()}');
    }
  }
  
  // 用于手动刷新页面
  Future<void> refreshPage() async {
    await _refreshUserProfile();
    await loadUserProjects();
    await loadAttendanceRecords();
    await loadAttendanceStatistics();
    await checkTodayAttendanceStatus();
  }
} 
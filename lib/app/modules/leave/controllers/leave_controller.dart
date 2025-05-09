import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/leave_model.dart';
import 'package:job_seeker_app/app/models/project_member_model.dart';
import 'package:job_seeker_app/app/services/api/leave_api_service.dart';
import 'package:job_seeker_app/app/services/api/project_member_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveController extends GetxController with StateMixin<List<LeaveModel>> {
  final LeaveApiService _leaveApiService = LeaveApiService();
  final ProjectMemberApiService _projectMemberApiService = ProjectMemberApiService();
  
  // 请假记录列表
  final RxList<LeaveModel> leaveRecords = <LeaveModel>[].obs;
  
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
  final RxBool isSubmitting = false.obs;
  
  // 筛选参数
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<int?> selectedProjectId = Rx<int?>(null);
  final Rx<LeaveStatus?> selectedStatus = Rx<LeaveStatus?>(null);
  
  // 用户ID
  late final RxInt userId = 0.obs;
  
  // 项目列表 (从API获取)
  final RxList<ProjectMemberModel> projects = <ProjectMemberModel>[].obs;
  
  // 新请假申请的表单控制器
  late TextEditingController reasonController;
  
  // 新请假申请的开始和结束日期
  final Rx<DateTime> newLeaveStartDate = DateTime.now().obs;
  final Rx<DateTime> newLeaveEndDate = DateTime.now().add(const Duration(days: 1)).obs;
  
  // 请假类型
  final Rx<LeaveType> selectedLeaveType = LeaveType.personal.obs;
  
  // 请假类型列表
  final List<Map<String, dynamic>> leaveTypeList = [
    {'type': LeaveType.personal, 'name': '事假'},
    {'type': LeaveType.sick, 'name': '病假'},
    {'type': LeaveType.annual, 'name': '年假'},
    {'type': LeaveType.other, 'name': '其他'},
  ];
  
  // 请假状态列表
  final List<Map<String, dynamic>> leaveStatusList = [
    {'status': null, 'name': '全部'},
    {'status': LeaveStatus.pending, 'name': '待审批'},
    {'status': LeaveStatus.approved, 'name': '已批准'},
    {'status': LeaveStatus.rejected, 'name': '已拒绝'},
    {'status': LeaveStatus.cancelled, 'name': '已取消'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    
    // 初始化表单控制器
    reasonController = TextEditingController();
    
    // 初始化日期范围为当月
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, 1);
    endDate.value = now;
    
    // 获取用户ID
    _getUserId().then((_) {
      // 不再立即加载所有项目，而是在需要时通过loadLeaveRecords方法加载当前入职项目
      
      // 加载请假记录
      loadLeaveRecords();
    });
  }
  
  @override
  void onClose() {
    // 释放资源
    reasonController.dispose();
    super.onClose();
  }
  
  // 获取用户ID
  Future<void> _getUserId() async {
    try {
      print('请假管理: 开始获取用户ID');
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      
      print('请假管理: 从SharedPreferences获取到用户ID: $id');
      
      if (id != null && id > 0) {
        userId.value = id;
        print('请假管理: 成功设置用户ID: ${userId.value}');
        return;
      } else {
        print('请假管理: 获取的用户ID无效: $id，尝试备用方案');
        
        // 尝试从用户模块获取当前登录用户
        final currentId = await _tryGetCurrentUserId();
        if (currentId != null && currentId > 0) {
          print('请假管理: 从备用方案获取到有效ID: $currentId');
          userId.value = currentId;
          // 保存到SharedPreferences以便下次使用
          await prefs.setInt('user_id', currentId);
          print('请假管理: 已保存用户ID到本地存储');
          return;
        }
        
        print('请假管理: 所有获取用户ID尝试都失败');
        _showLoginRequiredMessage();
      }
    } catch (e) {
      print('请假管理: 获取用户ID过程中发生错误: ${e.toString()}');
      _showLoginRequiredMessage();
    }
  }
  
  // 尝试从其他途径获取当前用户ID
  Future<int?> _tryGetCurrentUserId() async {
    try {
      // 此处使用硬编码ID仅用于测试
      // 实际应用中应当修改为API调用获取当前登录用户
      print('请假管理: 使用测试用户ID: 1');
      return 1;
    } catch (e) {
      print('请假管理: 尝试获取用户ID时出错: $e');
      return null;
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
  
  // 加载请假记录
  Future<void> loadLeaveRecords({bool isRefresh = false}) async {
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

      print('请假管理: 开始加载请假记录: page=${currentPage.value}, size=$pageSize, projectId=${selectedProjectId.value}, status=${selectedStatus.value}, userId=${userId.value}');
      
      // 检查用户ID是否有效
      if (userId.value <= 0) {
        print('请假管理: 用户ID无效 (${userId.value})，重新尝试获取');
        await _getUserId();
        
        // 再次检查
        if (userId.value <= 0) {
          print('请假管理: 用户ID获取失败，无法加载请假记录');
          change(null, status: RxStatus.error('用户ID获取失败'));
          return;
        }
      }
      
      // 如果没有指定项目ID，先尝试获取当前用户入职的项目ID
      if (selectedProjectId.value == null || (selectedProjectId.value ?? 0) <= 0) {
        print('请假管理: 未指定项目ID，尝试获取当前用户入职的项目ID');
        try {
          final activeProjectResponse = await _projectMemberApiService.getCurrentUserActiveProject();
          if (activeProjectResponse.isSuccess && activeProjectResponse.data != null) {
            selectedProjectId.value = activeProjectResponse.data;
            print('请假管理: 成功获取当前用户入职的项目ID: ${selectedProjectId.value}');
          } else {
            print('请假管理: 获取当前用户入职项目ID失败，尝试加载用户所有项目');
            // 如果获取当前入职项目失败，则加载用户参与的所有项目
            if (projects.isEmpty) {
              await loadUserProjects();
              
              // 如果项目列表不为空，选择第一个项目
              if (projects.isNotEmpty) {
                selectedProjectId.value = projects[0].projectId;
                print('请假管理: 从用户项目列表中选择项目ID: ${selectedProjectId.value}');
              }
            }
          }
        } catch (e) {
          print('请假管理: 获取当前用户入职项目ID异常: ${e.toString()}');
        }
      }
      
      // 如果仍未获取到项目ID，则使用默认值
      if (selectedProjectId.value == null || (selectedProjectId.value ?? 0) <= 0) {
        print('请假管理: 警告 - 无法获取有效的项目ID，将使用默认值');
      }
      
      final response = await _leaveApiService.getMyLeaveRecords(
        projectId: selectedProjectId.value,
        status: selectedStatus.value,
        page: currentPage.value,
        size: pageSize,
      );
      
      print('请假管理: 请假记录响应: code=${response.code}, message=${response.message}, isSuccess=${response.isSuccess}');
      
      if (response.isSuccess) {
        final data = response.data;
        if (data != null) {
          final List<LeaveModel> records = data['records'] ?? [];
          
          // 忽略返回的total值，直接使用records的实际长度
          final int total = records.length;
          
          // 使用最小值1避免分页问题
          final int pages = (data['pages'] ?? 1) > 0 ? (data['pages'] ?? 1) : 1;
          
          print('请假管理: 请假记录数据: 记录数=${records.length}, 总记录数=$total, 总页数=$pages');
          
          if (isRefresh || currentPage.value == 1) {
            leaveRecords.clear();
          }
          
          leaveRecords.addAll(records);
          totalItems.value = total;
          totalPages.value = pages;
          
          if (leaveRecords.isEmpty) {
            print('请假管理: 无请假记录，显示空状态');
            change(leaveRecords, status: RxStatus.empty());
          } else {
            print('请假管理: 成功加载请假记录，显示数据');
            change(leaveRecords, status: RxStatus.success());
          }
        } else {
          print('请假管理: 响应数据为空');
          if (currentPage.value == 1) {
            leaveRecords.clear();
            change([], status: RxStatus.empty());
          }
        }
      } else {
        print('请假管理: 加载请假记录失败: ${response.message}');
        if (currentPage.value == 1) {
          leaveRecords.clear();
          change(null, status: RxStatus.error(response.message));
          
          Get.snackbar(
            '错误',
            '加载请假记录失败: ${response.message}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('请假管理: 加载请假记录异常: ${e.toString()}');
      if (currentPage.value == 1) {
        leaveRecords.clear();
        change(null, status: RxStatus.error(e.toString()));
        
        Get.snackbar(
          '错误',
          '加载请假记录失败: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
      isRefreshing.value = false;
    }
  }
  
  // 加载更多请假记录
  void loadMore() {
    if (currentPage.value < totalPages.value && !isMoreLoading.value) {
      currentPage.value++;
      loadLeaveRecords();
    }
  }
  
  // 刷新请假记录
  Future<void> refreshLeaveRecords() async {
    print('开始刷新请假记录，重置分页参数');
    // 重置分页参数
    currentPage.value = 1;
    
    // 获取用户ID（如果为空）
    if (userId.value <= 0) {
      print('刷新请假记录：用户ID为空，尝试获取用户ID');
      await _getUserId();
      print('刷新请假记录：获取用户ID结果：${userId.value}');
    }
    
    // 确保获取到了用户ID
    if (userId.value <= 0) {
      print('刷新请假记录：获取用户ID失败，无法获取请假记录');
      Get.snackbar(
        '错误',
        '无法获取您的用户信息，请尝试重新登录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // 不再默认加载所有项目，让loadLeaveRecords方法根据需要获取当前入职项目
    
    print('刷新请假记录：开始加载请假记录数据');
    await loadLeaveRecords(isRefresh: true);
    print('刷新请假记录：请假记录加载完成，记录数：${leaveRecords.length}');
  }
  
  // 应用筛选
  void applyFilter() {
    currentPage.value = 1;
    loadLeaveRecords(isRefresh: true);
  }
  
  // 重置筛选
  void resetFilter() {
    selectedStatus.value = null;
    
    if (projects.isNotEmpty) {
      selectedProjectId.value = projects[0].projectId;
    } else {
      selectedProjectId.value = null;
    }
    
    applyFilter();
  }
  
  // 格式化日期
  String formatDate(DateTime? date) {
    if (date == null) return '未知日期';
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // 提交请假申请
  Future<bool> submitLeaveRequest() async {
    try {
      if (selectedProjectId.value == null) {
        Get.snackbar(
          '错误',
          '请选择项目',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      if (reasonController.text.isEmpty) {
        Get.snackbar(
          '错误',
          '请填写请假原因',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      // 检查日期有效性
      if (newLeaveStartDate.value.isAfter(newLeaveEndDate.value)) {
        Get.snackbar(
          '错误',
          '开始日期不能晚于结束日期',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      isSubmitting.value = true;
      
      // 创建请假请求模型
      final leaveRequest = LeaveRequestModel(
        projectId: selectedProjectId.value!,
        type: selectedLeaveType.value,
        startTime: newLeaveStartDate.value,
        endTime: newLeaveEndDate.value,
        reason: reasonController.text.trim(),
      );
      
      print('正在提交请假申请: ${leaveRequest.toJson()}'); // 添加日志
      
      // 提交请假申请
      final response = await _leaveApiService.submitLeaveRequest(leaveRequest);
      
      print('请假申请响应: code=${response.code}, message=${response.message}, success=${response.isSuccess}'); // 添加日志
      
      if (response.isSuccess) {
        // 打印更多响应信息
        print('请假申请成功，响应数据: ${response.data}');
        
        // 此处保持Snackbar，因为AlertDialog已在视图中添加
        Get.snackbar(
          '成功',
          '请假申请提交成功',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // 重置表单
        reasonController.clear();
        newLeaveStartDate.value = DateTime.now();
        newLeaveEndDate.value = DateTime.now().add(const Duration(days: 1));
        
        // 刷新请假记录
        refreshLeaveRecords();
        
        return true;
      } else {
        print('请假申请失败: ${response.message}'); // 添加日志
        
        Get.snackbar(
          '错误',
          '请假申请提交失败: ${response.message}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5), // 延长显示时间
        );
        return false;
      }
    } catch (e) {
      print('请假申请异常: ${e.toString()}'); // 添加日志
      
      Get.snackbar(
        '错误',
        '请假申请提交失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5), // 延长显示时间
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
  
  // 取消请假申请
  Future<bool> cancelLeaveRequest(int leaveId) async {
    try {
      final response = await _leaveApiService.cancelLeaveRequest(leaveId);
      
      if (response.isSuccess && response.data == true) {
        Get.snackbar(
          '成功',
          '请假申请已取消',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        
        // 刷新请假记录
        refreshLeaveRecords();
        
        return true;
      } else {
        Get.snackbar(
          '错误',
          '取消请假申请失败: ${response.message}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '取消请假申请失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
  
  // 获取请假类型名称
  String getLeaveTypeName(LeaveType type) {
    final Map<String, dynamic>? typeData = leaveTypeList.firstWhereOrNull((element) => element['type'] == type);
    return typeData?['name'] ?? '未知类型';
  }
  
  // 获取请假状态名称
  String getLeaveStatusName(LeaveStatus status) {
    final Map<String, dynamic>? statusData = leaveStatusList.firstWhereOrNull((element) => element['status'] == status);
    return statusData?['name'] ?? '未知状态';
  }
  
  // 获取请假状态颜色
  Color getLeaveStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 
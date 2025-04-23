import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/labor_demand_model.dart';
import '../../../models/job_application_model.dart';
import '../../../services/api/labor_demand_api_service.dart';
import '../../../services/api/job_application_api_service.dart';

class JobDetailController extends GetxController {
  final LaborDemandApiService _laborDemandApiService = LaborDemandApiService();
  final JobApplicationApiService _jobApplicationApiService = JobApplicationApiService();

  // 职位详情数据
  final Rx<LaborDemandModel?> jobDetail = Rx<LaborDemandModel?>(null);
  
  // 加载状态控制
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // 申请相关控制
  final isSubmitting = false.obs;
  final submissionSuccess = false.obs;

  // 申请表单控制器
  late TextEditingController selfIntroductionController;
  late TextEditingController expectedSalaryController;
  late TextEditingController expectedStartDateController;
  
  // 职位ID
  final int jobId;
  
  // 构造函数接收职位ID
  JobDetailController({required this.jobId});

  @override
  void onInit() {
    super.onInit();
    // 初始化表单控制器
    selfIntroductionController = TextEditingController();
    expectedSalaryController = TextEditingController();
    expectedStartDateController = TextEditingController();
    
    // 加载职位详情
    fetchJobDetail();
  }

  @override
  void onClose() {
    // 释放表单控制器
    selfIntroductionController.dispose();
    expectedSalaryController.dispose();
    expectedStartDateController.dispose();
    super.onClose();
  }

  /// 获取职位详情
  Future<void> fetchJobDetail() async {
    try {
      // 设置加载状态
      isLoading.value = true;
      hasError.value = false;
      
      // 发送请求获取职位详情
      final response = await _laborDemandApiService.getLaborDemandDetail(jobId);
      
      // 处理响应结果
      if (response.isSuccess && response.data != null) {
        // 更新职位详情数据
        jobDetail.value = response.data;
        print('获取职位详情成功: ${response.data?.toJson()}');
      } else {
        // 设置错误状态
        hasError.value = true;
        errorMessage.value = response.message;
        print('获取职位详情失败: ${response.message}');
      }
    } catch (e) {
      // 设置错误状态
      hasError.value = true;
      errorMessage.value = e.toString();
      print('获取职位详情时发生错误: $e');
    } finally {
      // 结束加载状态
      isLoading.value = false;
    }
  }

  /// 刷新职位详情
  Future<void> refreshJobDetail() async {
    await fetchJobDetail();
  }

  /// 提交求职申请
  Future<bool> submitJobApplication() async {
    if (jobDetail.value == null) {
      Get.snackbar('错误', '职位信息不存在，无法提交申请');
      return false;
    }
    
    try {
      isSubmitting.value = true;
      submissionSuccess.value = false;
      
      // 获取表单数据
      final double? expectedSalary = expectedSalaryController.text.isNotEmpty
          ? double.tryParse(expectedSalaryController.text)
          : null;
      
      final String? expectedStartDate = expectedStartDateController.text.isNotEmpty
          ? expectedStartDateController.text
          : null;
          
      final String? selfIntroduction = selfIntroductionController.text.isNotEmpty
          ? selfIntroductionController.text
          : null;
      
      // 构建请求对象
      final request = JobApplicationRequest(
        demandId: jobDetail.value!.id,
        selfIntroduction: selfIntroduction,
        expectedSalary: expectedSalary,
        expectedStartDate: expectedStartDate,
      );
      
      print('正在提交求职申请: ${request.toJson()}');
      
      // 发送申请请求
      final response = await _jobApplicationApiService.submitJobApplication(request);
      
      print('申请响应: code=${response.code}, message=${response.message}');
      
      // 处理响应
      if (response.code == 0) { // 检查响应码是0表示成功
        submissionSuccess.value = true;
        // 强制重新构建UI以显示成功状态
        update();
        // 确保在UI线程上执行snackbar显示
        Future.microtask(() => Get.snackbar(
          '成功', 
          '求职申请已提交',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        ));
        return true;
      } else {
        print('申请失败: ${response.message}');
        Future.microtask(() => Get.snackbar(
          '失败', 
          '申请提交失败: ${response.message}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
        ));
        return false;
      }
    } catch (e) {
      print('申请提交过程中发生错误: $e');
      Future.microtask(() => Get.snackbar(
        '错误', 
        '申请提交过程中发生错误，请稍后重试',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 3),
      ));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
  
  /// 显示申请表单对话框
  void showApplicationForm() {
    // 清空控制器
    selfIntroductionController.clear();
    expectedSalaryController.clear();
    expectedStartDateController.clear();
    
    // 如果已有工资信息，预填期望工资
    if (jobDetail.value != null) {
      expectedSalaryController.text = jobDetail.value!.dailyWage.toString();
    }
    
    // 今天的日期作为默认开始日期
    final now = DateTime.now();
    final formatter = (date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    expectedStartDateController.text = formatter(now.add(const Duration(days: 3)));
    
    Get.dialog(
      AlertDialog(
        title: const Text('申请此职位'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: selfIntroductionController,
                decoration: const InputDecoration(
                  labelText: '自我介绍',
                  hintText: '请简要介绍您的工作经验和技能...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: expectedSalaryController,
                decoration: const InputDecoration(
                  labelText: '期望薪资 (元/天)',
                  hintText: '例如: 350',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: expectedStartDateController,
                decoration: const InputDecoration(
                  labelText: '期望入职日期',
                  hintText: 'YYYY-MM-DD',
                ),
                readOnly: true,
                onTap: () => _selectDate(Get.context!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isSubmitting.value
                ? null
                : () async {
                    final success = await submitJobApplication();
                    if (success) {
                      Get.back();
                    }
                  },
            child: isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('提交申请'),
          )),
        ],
      ),
    );
  }
  
  /// 日期选择器
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(expectedStartDateController.text);
    } catch (e) {
      initialDate = DateTime.now().add(const Duration(days: 3));
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      expectedStartDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }
} 
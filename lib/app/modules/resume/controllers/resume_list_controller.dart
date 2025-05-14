import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/resume_model.dart';
import '../../../services/api/resume_api_service.dart';
import '../../../routes/app_pages.dart';

class ResumeListController extends GetxController {
  final ResumeApiService _resumeApiService = ResumeApiService();
  
  // 简历列表数据
  final resumeList = <ResumeDTO>[].obs;
  
  // 状态控制变量
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchResumeList();
  }
  
  /// 获取简历列表
  Future<void> fetchResumeList() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final response = await _resumeApiService.getResumeList();
      
      if (response.isSuccess && response.data != null) {
        resumeList.value = response.data!;
        print('获取简历列表成功: ${resumeList.length}条记录');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        print('获取简历列表失败: ${response.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('获取简历列表时发生错误: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 刷新列表
  Future<void> onRefresh() async {
    await fetchResumeList();
  }
  
  /// 创建在线简历
  void createOnlineResume() {
    Get.toNamed(Routes.RESUME_ONLINE_EDIT);
  }
  
  /// 创建附件简历
  void createAttachmentResume() {
    Get.toNamed(Routes.RESUME_ATTACHMENT_UPLOAD);
  }
  
  /// 查看在线简历
  void viewOnlineResume(int resumeId) {
    Get.toNamed(Routes.RESUME_ONLINE_VIEW, arguments: {'resumeId': resumeId});
  }
  
  /// 查看附件简历
  void viewAttachmentResume(int resumeId) {
    Get.toNamed(Routes.RESUME_ATTACHMENT_VIEW, arguments: {'resumeId': resumeId});
  }
  
  /// 编辑在线简历
  void editOnlineResume(int resumeId) {
    Get.toNamed(Routes.RESUME_ONLINE_EDIT, arguments: {'resumeId': resumeId});
  }
  
  /// 设置默认简历
  Future<void> setDefaultResume(int resumeId) async {
    try {
      final response = await _resumeApiService.setDefaultResume(resumeId);
      
      if (response.isSuccess && response.data == true) {
        // 更新本地数据，将其他简历的默认状态设为false，当前简历设为true
        for (var resume in resumeList) {
          if (resume.id == resumeId) {
            final index = resumeList.indexWhere((element) => element.id == resumeId);
            if (index != -1) {
              final updatedResume = ResumeDTO(
                id: resume.id,
                userId: resume.userId,
                type: resume.type,
                title: resume.title,
                status: resume.status,
                isDefault: true,
                createTime: resume.createTime,
                updateTime: resume.updateTime,
              );
              resumeList[index] = updatedResume;
            }
          } else {
            final index = resumeList.indexWhere((element) => element.id == resume.id);
            if (index != -1) {
              final updatedResume = ResumeDTO(
                id: resume.id,
                userId: resume.userId,
                type: resume.type,
                title: resume.title,
                status: resume.status,
                isDefault: false,
                createTime: resume.createTime,
                updateTime: resume.updateTime,
              );
              resumeList[index] = updatedResume;
            }
          }
        }
        
        Get.snackbar('成功', '已设置为默认简历', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('失败', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('错误', '设置默认简历失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  /// 删除简历
  Future<void> deleteResume(int resumeId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这份简历吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      final response = await _resumeApiService.deleteResume(resumeId);
      
      if (response.isSuccess && response.data == true) {
        // 从列表中移除被删除的简历
        resumeList.removeWhere((resume) => resume.id == resumeId);
        Get.snackbar('成功', '简历已删除', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('失败', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('错误', '删除简历失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
} 
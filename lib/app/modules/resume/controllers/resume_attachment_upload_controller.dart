import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api/resume_api_service.dart';
import '../../../services/api/file_api_service.dart';
import '../../../routes/app_pages.dart';

class ResumeAttachmentUploadController extends GetxController {
  final ResumeApiService _resumeApiService = ResumeApiService();
  final FileApiService _fileApiService = FileApiService();
  
  // 表单 key
  final formKey = GlobalKey<FormState>();
  
  // 简历信息
  final titleController = TextEditingController();
  final isDefault = true.obs;
  
  // 文件信息
  final selectedFileName = Rx<String?>(null);
  final selectedFileSize = Rx<int?>(null);
  final selectedFileType = Rx<String?>(null);
  final selectedFilePath = Rx<String?>(null);
  
  // 状态
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    titleController.text = '我的附件简历';
  }
  
  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
  
  // 选择文件
  Future<void> pickFile() async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('选择文件功能'),
          content: const Text('文件上传功能即将上线，敬请期待！'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      
      // 模拟选择文件
      selectedFileName.value = '我的简历.pdf';
      selectedFileSize.value = 1024 * 500; // 500KB
      selectedFileType.value = 'application/pdf';
      selectedFilePath.value = '/mock/path/resume.pdf';
    } catch (e) {
      Get.snackbar('错误', '选择文件失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 上传简历
  Future<void> uploadResume() async {
    try {
      // 表单验证
      if (formKey.currentState?.validate() != true) {
        return;
      }
      
      // 检查是否选择了文件
      if (selectedFilePath.value == null || selectedFileName.value == null) {
        Get.snackbar('提示', '请先选择简历文件', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // 开始上传
      isUploading.value = true;
      uploadProgress.value = 0.0;
      
      // 构建简历数据
      final resumeData = {
        'resumeInfo': {
          'title': titleController.text,
          'isDefault': isDefault.value,
          'status': 'published',
          'type': 'attachment',
        },
        'fileName': selectedFileName.value,
        'fileSize': selectedFileSize.value,
        'fileType': selectedFileType.value,
        'fileUrl': '/mock/uploads/${selectedFileName.value}', // 模拟上传后的URL
      };
      
      // 模拟上传进度
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        uploadProgress.value = i / 10;
      }
      
      // 创建简历记录
      final response = await _resumeApiService.createAttachmentResume(resumeData);
      
      if (response.isSuccess && response.data != null) {
        Get.snackbar('成功', '简历已上传', snackPosition: SnackPosition.BOTTOM);
        Get.offNamed(Routes.RESUME_LIST);
      } else {
        Get.snackbar('失败', '上传简历失败: ${response.message}', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('错误', '上传简历失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }
  
  // 取消上传
  void cancelUpload() {
    // 取消上传逻辑
    Get.back();
  }
  
  // 格式化文件大小
  String formatFileSize(int? bytes) {
    if (bytes == null) return '未知大小';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
} 
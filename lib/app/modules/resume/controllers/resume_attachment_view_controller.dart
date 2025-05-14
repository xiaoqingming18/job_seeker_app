import 'package:get/get.dart';
import '../../../models/resume_model.dart';
import '../../../services/api/resume_api_service.dart';
import '../../../routes/app_pages.dart';

class ResumeAttachmentViewController extends GetxController {
  final ResumeApiService _resumeApiService = ResumeApiService();
  
  // 简历 ID
  final resumeId = Rx<int?>(null);
  
  // 简历数据
  final resume = Rx<AttachmentResumeDTO?>(null);
  
  // 页面状态
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // 正在打开文件
  final isOpeningFile = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // 获取传入的简历ID
    if (Get.arguments != null && Get.arguments['resumeId'] != null) {
      resumeId.value = Get.arguments['resumeId'];
      fetchResumeDetails();
    } else {
      hasError.value = true;
      errorMessage.value = '未找到简历ID';
      isLoading.value = false;
    }
  }
  
  // 获取简历详情
  Future<void> fetchResumeDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      if (resumeId.value == null) {
        throw Exception('简历ID不能为空');
      }
      
      final response = await _resumeApiService.getAttachmentResumeDetail(resumeId.value!);
      
      if (response.isSuccess && response.data != null) {
        resume.value = response.data;
        print('获取附件简历详情成功');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        print('获取附件简历详情失败: ${response.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('获取附件简历详情时发生错误: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // 刷新简历
  Future<void> onRefresh() async {
    await fetchResumeDetails();
  }
  
  // 打开附件文件
  Future<void> openFile() async {
    try {
      isOpeningFile.value = true;
      
      // 模拟打开文件
      await Future.delayed(const Duration(seconds: 2));
      
      Get.snackbar('提示', '文件查看功能即将上线，敬请期待！', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('错误', '打开文件失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isOpeningFile.value = false;
    }
  }
  
  // 设置为默认简历
  Future<void> setAsDefault() async {
    try {
      if (resumeId.value == null) {
        throw Exception('简历ID不能为空');
      }
      
      // 已经是默认简历，不需要设置
      if (resume.value?.resumeInfo?.isDefault == true) {
        Get.snackbar('提示', '此简历已是默认简历', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      final response = await _resumeApiService.setDefaultResume(resumeId.value!);
      
      if (response.isSuccess && response.data == true) {
        // 更新本地数据
        if (resume.value != null && resume.value!.resumeInfo != null) {
          final updatedResumeInfo = ResumeDTO(
            id: resume.value!.resumeInfo!.id,
            userId: resume.value!.resumeInfo!.userId,
            type: resume.value!.resumeInfo!.type,
            title: resume.value!.resumeInfo!.title,
            status: resume.value!.resumeInfo!.status,
            isDefault: true,
            createTime: resume.value!.resumeInfo!.createTime,
            updateTime: resume.value!.resumeInfo!.updateTime,
          );
          
          final updatedResume = AttachmentResumeDTO(
            id: resume.value!.id,
            resumeId: resume.value!.resumeId,
            resumeInfo: updatedResumeInfo,
            fileName: resume.value!.fileName,
            fileUrl: resume.value!.fileUrl,
            fileSize: resume.value!.fileSize,
            fileType: resume.value!.fileType,
            createTime: resume.value!.createTime,
            updateTime: resume.value!.updateTime,
          );
          
          resume.value = updatedResume;
        }
        
        Get.snackbar('成功', '已设置为默认简历', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('失败', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('错误', '设置默认简历失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
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
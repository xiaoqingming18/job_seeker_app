import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import '../../../services/api/user_api_service.dart';

class ProfileEditController extends GetxController {
  final UserApiService _userApiService = UserApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // 用户资料
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  
  // 表单控制器
  late TextEditingController usernameController;
  late TextEditingController realNameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController expectPositionController;
  late TextEditingController workYearsController;
  late TextEditingController skillController;
  late TextEditingController certificatesController;
  
  // 性别选择
  final Rx<String?> selectedGender = Rx<String?>(null);
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // 初始化控制器
    usernameController = TextEditingController();
    realNameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();
    expectPositionController = TextEditingController();
    workYearsController = TextEditingController();
    skillController = TextEditingController();
    certificatesController = TextEditingController();
    
    // 加载用户资料
    loadUserProfile();
  }
  
  @override
  void onClose() {
    // 释放控制器资源
    usernameController.dispose();
    realNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    expectPositionController.dispose();
    workYearsController.dispose();
    skillController.dispose();
    certificatesController.dispose();
    super.onClose();
  }
  
  /// 加载用户资料
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    try {
      // 先尝试从缓存中获取用户资料
      final cachedProfile = await _userApiService.getCachedJobseekerProfile();
      if (cachedProfile != null) {
        userProfile.value = cachedProfile;
        _updateFormControllers(cachedProfile);
      } else {
        // 如果缓存中没有，则从服务器获取
        final response = await _userApiService.fetchAndCacheJobseekerProfile();
        if (response.isSuccess && response.data != null) {
          userProfile.value = response.data;
          _updateFormControllers(response.data!);
        } else {
          Get.snackbar('错误', '获取用户资料失败：${response.message}');
        }
      }
    } catch (e) {
      Get.snackbar('错误', '加载用户资料时发生错误：${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 更新表单控制器的值
  void _updateFormControllers(UserModel profile) {
    usernameController.text = profile.username ?? '';
    realNameController.text = profile.realName ?? '';
    mobileController.text = profile.mobile ?? '';
    emailController.text = profile.email ?? '';
    expectPositionController.text = profile.expectPosition ?? '';
    workYearsController.text = profile.workYears?.toString() ?? '';
    skillController.text = profile.skill ?? '';
    certificatesController.text = profile.certificates ?? '';
    selectedGender.value = profile.gender;
  }
  
  /// 格式化列表字段为JSON数组
  String _formatListField(String input) {
    if (input.isEmpty) return '[]';
    final items = input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    return '[${items.map((e) => '"\$e"').join(',')}]';
  }

  /// 保存用户资料
  Future<void> saveUserProfile() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }
    
    isSaving.value = true;
    try {
      final response = await _userApiService.updateJobseekerInfo(
        mobile: mobileController.text.trim().isNotEmpty ? mobileController.text.trim() : null,
        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        realName: realNameController.text.trim().isNotEmpty ? realNameController.text.trim() : null,
        gender: selectedGender.value,
        expectPosition: expectPositionController.text.trim().isNotEmpty ? expectPositionController.text.trim() : null,
        workYears: workYearsController.text.trim().isNotEmpty ? int.tryParse(workYearsController.text.trim()) : null,
        skill: skillController.text.trim().isNotEmpty ? _formatListField(skillController.text.trim()) : null,
        certificates: certificatesController.text.trim().isNotEmpty ? _formatListField(certificatesController.text.trim()) : null,
      );
      
      if (response.isSuccess && response.data != null) {
        // 更新成功，更新本地缓存
        await _userApiService.fetchAndCacheJobseekerProfile();
        Get.snackbar('操作成功', '用户资料已更新',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          onTap: (_) => Get.back(),
          snackbarStatus: (status) {
            if (status == SnackbarStatus.CLOSED) {
              Get.back(); // 在提示关闭后返回上一页
            }
          }
        );
      } else {
        Get.snackbar('错误', '更新用户资料失败：${response.message}');
      }
    } catch (e) {
      Get.snackbar('错误', '保存用户资料时发生错误：${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }
}

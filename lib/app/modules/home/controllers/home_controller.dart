import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/api/http_client.dart';
import '../../../services/api/user_api_service.dart';

class HomeController extends GetxController {
  // 控制器状态或变量
  final count = 0.obs;
  
  // API 服务
  final UserApiService _userApiService = UserApiService();
  final HttpClient _httpClient = HttpClient();

  @override
  void onInit() {
    super.onInit();
    // 初始化逻辑
  }

  @override
  void onReady() {
    super.onReady();
    // 页面加载完成后的逻辑
  }

  @override
  void onClose() {
    super.onClose();
    // 清理资源
  }

  // 增加计数的方法（示例）
  void increment() => count.value++;
  
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

import 'package:get/get.dart';

class HomeController extends GetxController {
  // 控制器状态或变量
  final count = 0.obs;

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
}

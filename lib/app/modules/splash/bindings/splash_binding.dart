import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

/// 启动页模块依赖绑定
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
  }
}

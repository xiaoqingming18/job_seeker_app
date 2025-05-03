import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/im_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    
    Get.lazyPut<ImController>(
      () => ImController(),
    );
  }
}

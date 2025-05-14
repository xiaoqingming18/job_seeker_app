import 'package:get/get.dart';
import '../controllers/resume_online_edit_controller.dart';

class ResumeOnlineEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumeOnlineEditController>(
      () => ResumeOnlineEditController(),
    );
  }
} 
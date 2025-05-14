import 'package:get/get.dart';
import '../controllers/resume_list_controller.dart';

class ResumeListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumeListController>(
      () => ResumeListController(),
    );
  }
} 
import 'package:get/get.dart';
import '../controllers/resume_online_view_controller.dart';

class ResumeOnlineViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumeOnlineViewController>(
      () => ResumeOnlineViewController(),
    );
  }
} 
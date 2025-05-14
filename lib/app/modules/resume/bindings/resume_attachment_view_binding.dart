import 'package:get/get.dart';
import '../controllers/resume_attachment_view_controller.dart';

class ResumeAttachmentViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumeAttachmentViewController>(
      () => ResumeAttachmentViewController(),
    );
  }
} 
import 'package:get/get.dart';
import '../controllers/resume_attachment_upload_controller.dart';

class ResumeAttachmentUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumeAttachmentUploadController>(
      () => ResumeAttachmentUploadController(),
    );
  }
} 
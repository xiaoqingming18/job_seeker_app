import 'package:get/get.dart';
import 'package:job_seeker_app/app/modules/certificate/controllers/certificate_edit_controller.dart';
import 'package:job_seeker_app/app/services/api/certificate_api_service.dart';

class CertificateEditBinding extends Bindings {
  @override
  void dependencies() {
    // 确保API服务已注册
    if (!Get.isRegistered<CertificateApiService>()) {
      Get.lazyPut<CertificateApiService>(
        () => CertificateApiService(),
      );
    }
    
    // 注册证书编辑控制器
    Get.lazyPut<CertificateEditController>(
      () => CertificateEditController(),
    );
  }
} 
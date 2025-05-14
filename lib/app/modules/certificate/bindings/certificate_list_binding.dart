import 'package:get/get.dart';
import 'package:job_seeker_app/app/modules/certificate/controllers/certificate_list_controller.dart';
import 'package:job_seeker_app/app/services/api/certificate_api_service.dart';

class CertificateListBinding extends Bindings {
  @override
  void dependencies() {
    // 注册证书API服务
    Get.lazyPut<CertificateApiService>(
      () => CertificateApiService(),
    );
    
    // 注册证书列表控制器
    Get.lazyPut<CertificateListController>(
      () => CertificateListController(),
    );
  }
} 
import 'package:get/get.dart';
import '../controllers/salary_detail_controller.dart';
import '../../../services/api/salary_api_service.dart';

class SalaryDetailBinding extends Bindings {
  @override
  void dependencies() {
    // 注册SalaryApiService如果尚未注册
    if (!Get.isRegistered<SalaryApiService>()) {
      Get.lazyPut<SalaryApiService>(
        () => SalaryApiService(),
      );
    }
    
    // 通过传递的工资ID参数初始化SalaryDetailController
    Get.lazyPut<SalaryDetailController>(
      () => SalaryDetailController(salaryId: int.parse(Get.parameters['id'] ?? '0')),
    );
  }
} 
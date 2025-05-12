import 'package:get/get.dart';
import '../controllers/salary_controller.dart';
import '../../../services/api/salary_api_service.dart';

class SalaryBinding extends Bindings {
  @override
  void dependencies() {
    // 注册SalaryApiService
    Get.lazyPut<SalaryApiService>(
      () => SalaryApiService(),
    );
    
    // 注册SalaryController
    Get.lazyPut<SalaryController>(
      () => SalaryController(),
    );
  }
} 
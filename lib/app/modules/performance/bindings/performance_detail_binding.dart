import 'package:get/get.dart';
import '../controllers/performance_detail_controller.dart';

class PerformanceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerformanceDetailController>(
      () => PerformanceDetailController(
        performanceId: int.tryParse(Get.parameters['id'] ?? '0') ?? 0,
      ),
    );
  }
} 
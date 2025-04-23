import 'package:get/get.dart';
import '../controllers/job_detail_controller.dart';

class JobDetailBinding extends Bindings {
  @override
  void dependencies() {
    // 从参数中获取职位ID并注入控制器
    final jobId = int.parse(Get.parameters['id'] ?? '0');
    Get.lazyPut<JobDetailController>(
      () => JobDetailController(jobId: jobId),
    );
  }
} 
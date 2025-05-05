import 'package:get/get.dart';

import '../controllers/labor_demand_search_controller.dart';

class LaborDemandSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaborDemandSearchController>(
      () => LaborDemandSearchController(),
    );
  }
} 
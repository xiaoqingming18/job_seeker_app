import 'package:get/get.dart';
import '../../../models/salary_model.dart';
import '../../../services/api/salary_api_service.dart';

class SalaryDetailController extends GetxController {
  // 依赖注入
  final SalaryApiService _salaryApiService = Get.find<SalaryApiService>();
  
  // 工资ID
  final int salaryId;
  
  // 状态变量
  final RxBool isLoading = true.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // 数据变量
  final Rx<SalaryModel?> salary = Rx<SalaryModel?>(null);
  
  // 构造函数
  SalaryDetailController({required this.salaryId});
  
  @override
  void onInit() {
    super.onInit();
    loadSalaryDetail();
  }
  
  // 加载工资详情
  Future<void> loadSalaryDetail() async {
    try {
      isLoading.value = true;
      isError.value = false;
      
      final result = await _salaryApiService.getSalaryDetail(salaryId);
      salary.value = SalaryModel.fromJson(result);
    } catch (e) {
      isError.value = true;
      errorMessage.value = '加载工资详情失败：${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
  
  // 重试加载
  void retry() {
    loadSalaryDetail();
  }
  
  // 格式化金额
  String formatAmount(double? amount) {
    if (amount == null) return '¥0.00';
    return '¥${amount.toStringAsFixed(2)}';
  }
} 
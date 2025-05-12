import 'package:get/get.dart';
import '../../../models/salary_model.dart';
import '../../../services/api/salary_api_service.dart';
import '../../../routes/app_pages.dart';

class SalaryController extends GetxController {
  // 服务实例
  final SalaryApiService _salaryApiService = Get.find<SalaryApiService>();
  
  // 状态变量
  final RxBool isLoading = true.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // 数据变量
  final RxList<SalaryModel> salaries = <SalaryModel>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasMore = true.obs;
  
  // 每页加载的数量
  final int pageSize = 10;
  
  @override
  void onInit() {
    super.onInit();
    loadSalaries();
  }
  
  // 加载工资列表数据
  Future<void> loadSalaries({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      salaries.clear();
    }
    
    try {
      isLoading.value = true;
      isError.value = false;
      
      final result = await _salaryApiService.getPersonalSalaryList(
        current: currentPage.value,
        size: pageSize,
      );
      
      final List<dynamic> records = result['records'] ?? [];
      totalItems.value = result['total'] ?? 0;
      
      final newSalaries = records
          .map((json) => SalaryModel.fromJson(json))
          .toList();
      
      if (refresh) {
        salaries.value = newSalaries;
      } else {
        salaries.addAll(newSalaries);
      }
      
      // 判断是否还有更多数据
      hasMore.value = salaries.length < totalItems.value;
      
      // 更新分页
      if (hasMore.value) {
        currentPage.value++;
      }
      
      // 如果没有数据，显示友好提示
      if (salaries.isEmpty && !isError.value) {
        errorMessage.value = '暂无工资数据，请联系您的项目经理了解详情。';
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = '加载工资数据失败：${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
  
  // 刷新数据
  void onRefresh() async {
    await loadSalaries(refresh: true);
  }
  
  // 加载更多数据
  void onLoadMore() async {
    if (hasMore.value) {
      await loadSalaries();
    }
  }
  
  // 导航到工资详情页面
  void navigateToSalaryDetail(int salaryId) {
    Get.toNamed(
      Routes.SALARY_DETAIL,
      parameters: {'id': salaryId.toString()},
    );
  }
  
  // 格式化金额
  String formatAmount(double? amount) {
    if (amount == null) return '¥0.00';
    return '¥${amount.toStringAsFixed(2)}';
  }
} 
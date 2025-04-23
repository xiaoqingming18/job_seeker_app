import 'package:get/get.dart';
import '../../../models/labor_demand_model.dart';
import '../../../services/api/labor_demand_api_service.dart';

class JobDetailController extends GetxController {
  final LaborDemandApiService _laborDemandApiService = LaborDemandApiService();

  // 职位详情数据
  final Rx<LaborDemandModel?> jobDetail = Rx<LaborDemandModel?>(null);
  
  // 加载状态控制
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // 职位ID
  final int jobId;
  
  // 构造函数接收职位ID
  JobDetailController({required this.jobId});

  @override
  void onInit() {
    super.onInit();
    // 加载职位详情
    fetchJobDetail();
  }

  /// 获取职位详情
  Future<void> fetchJobDetail() async {
    try {
      // 设置加载状态
      isLoading.value = true;
      hasError.value = false;
      
      // 发送请求获取职位详情
      final response = await _laborDemandApiService.getLaborDemandDetail(jobId);
      
      // 处理响应结果
      if (response.isSuccess && response.data != null) {
        // 更新职位详情数据
        jobDetail.value = response.data;
        print('获取职位详情成功: ${response.data?.toJson()}');
      } else {
        // 设置错误状态
        hasError.value = true;
        errorMessage.value = response.message;
        print('获取职位详情失败: ${response.message}');
      }
    } catch (e) {
      // 设置错误状态
      hasError.value = true;
      errorMessage.value = e.toString();
      print('获取职位详情时发生错误: $e');
    } finally {
      // 结束加载状态
      isLoading.value = false;
    }
  }

  /// 刷新职位详情
  Future<void> refreshJobDetail() async {
    await fetchJobDetail();
  }
} 
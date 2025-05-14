import 'package:get/get.dart';
import 'package:job_seeker_app/app/models/certificate_model.dart';
import 'package:job_seeker_app/app/services/api/certificate_api_service.dart';

/// 证书列表控制器
class CertificateListController extends GetxController {
  // API服务
  final CertificateApiService _certificateApiService = Get.find<CertificateApiService>();
  
  // 证书列表
  final RxList<Certificate> certificates = <Certificate>[].obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  
  // 刷新控制器
  final RxBool isRefreshing = false.obs;
  
  // 分页参数
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 10.obs;
  final RxInt total = 0.obs;
  
  // 筛选参数
  final RxString statusFilter = ''.obs;
  
  // 是否还有更多数据
  bool get hasMore => certificates.length < total.value;
  
  @override
  void onInit() {
    super.onInit();
    loadCertificates();
  }
  
  /// 加载证书列表
  Future<void> loadCertificates() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final response = await _certificateApiService.getMyCertificates(
        page: currentPage.value,
        size: pageSize.value,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
      );
      
      if (currentPage.value == 1) {
        certificates.clear();
      }
      
      certificates.addAll(response.records);
      total.value = response.total;
    } catch (e) {
      Get.snackbar('错误', '获取证书列表失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
  
  /// 刷新数据
  Future<void> refreshData() async {
    isRefreshing.value = true;
    currentPage.value = 1;
    await loadCertificates();
  }
  
  /// 加载更多
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore) return;
    
    currentPage.value++;
    await loadCertificates();
  }
  
  /// 设置状态筛选
  void setStatusFilter(String status) {
    if (statusFilter.value == status) return;
    
    statusFilter.value = status;
    currentPage.value = 1;
    loadCertificates();
  }
  
  /// 删除证书
  Future<void> deleteCertificate(int certificateId) async {
    try {
      await _certificateApiService.deleteCertificate(certificateId);
      certificates.removeWhere((cert) => cert.id == certificateId);
      Get.snackbar('成功', '证书已删除');
    } catch (e) {
      Get.snackbar('错误', '删除证书失败: ${e.toString()}');
    }
  }
} 
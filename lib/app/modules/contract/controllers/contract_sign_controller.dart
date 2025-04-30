import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api/labor_contract_api_service.dart';

class ContractSignController extends GetxController {
  final LaborContractApiService _contractApiService = LaborContractApiService();
  
  // 合同编号
  final String contractCode;
  
  // 合同详情数据
  final contractDetail = Rx<Map<String, dynamic>?>(null);
  
  // 加载状态
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // 签署状态
  final isSigned = false.obs;
  
  ContractSignController({required this.contractCode});
  
  @override
  void onInit() {
    super.onInit();
    // 初始化时获取合同详情
    fetchContractDetail();
  }
  
  /// 获取合同详情
  Future<void> fetchContractDetail() async {
    try {
      // 设置加载状态
      isLoading.value = true;
      hasError.value = false;
      
      // 发送获取详情请求
      final response = await _contractApiService.getContractDetail(
        contractCode: contractCode,
      );
      
      // 处理响应结果
      if (response.isSuccess && response.data != null) {
        contractDetail.value = response.data;
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        Get.snackbar(
          '获取合同详情失败',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        '获取合同详情失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 签署合同
  Future<void> signContract() async {
    try {
      // 设置加载状态
      isLoading.value = true;
      hasError.value = false;
      
      // 发送签署请求
      final response = await _contractApiService.signContract(
        contractCode: contractCode,
      );
      
      // 处理响应结果
      if (response.isSuccess) {
        isSigned.value = true;
        // 刷新合同详情
        await fetchContractDetail();
        Get.snackbar(
          '签署成功',
          '合同已成功签署，等待审核',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
        // 延迟返回上一页
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        Get.snackbar(
          '签署失败',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        '签署失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
} 
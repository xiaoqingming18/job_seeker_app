import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/performance_model.dart';
import 'package:job_seeker_app/app/services/api/performance_api_service.dart';

class PerformanceDetailController extends GetxController {
  final PerformanceApiService _performanceApiService = PerformanceApiService();
  
  // 绩效评估ID
  final int performanceId;
  
  // 加载状态
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // 绩效评估详情
  final performance = Rxn<PerformanceModel>(null);
  
  PerformanceDetailController({required this.performanceId});
  
  @override
  void onInit() {
    super.onInit();
    // 初始化时加载评估详情
    loadPerformanceDetail();
  }
  
  /// 加载绩效评估详情
  Future<void> loadPerformanceDetail() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final response = await _performanceApiService.getPerformanceInfo(performanceId);
      
      if (response.isSuccess && response.data != null) {
        performance.value = response.data;
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 格式化日期显示
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  /// 获取评分的颜色
  Color getScoreColor(int score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
  
  /// 获取总分的颜色
  Color getTotalScoreColor(double score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
  
  /// 获取得分评级文本
  String getScoreRating(double score) {
    if (score >= 9) return '优秀';
    if (score >= 7) return '良好';
    if (score >= 5) return '合格';
    return '需改进';
  }
} 
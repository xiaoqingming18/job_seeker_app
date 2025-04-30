import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import 'http_client.dart';

/// 劳务合同API服务
class LaborContractApiService {
  final HttpClient _httpClient = HttpClient();
  
  /// 获取合同详情
  Future<ApiResponse<Map<String, dynamic>>> getContractDetail({
    required String contractCode,
  }) async {
    try {
      // 发送请求
      final response = await _httpClient.get(
        '/labor-contracts/code/$contractCode',
      );
      
      // 解析响应数据
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      
      return apiResponse;
    } on DioException catch (e) {
      // 处理Dio异常
      final message = e.response?.data?['message'] ?? e.message ?? '网络请求失败';
      return ApiResponse<Map<String, dynamic>>(
        code: e.response?.statusCode ?? -1,
        message: message,
        data: null,
      );
    } catch (e) {
      // 处理其他异常
      return ApiResponse<Map<String, dynamic>>(
        code: -1,
        message: e.toString(),
        data: null,
      );
    }
  }
  
  /// 签署劳务合同
  Future<ApiResponse<Map<String, dynamic>>> signContract({
    required String contractCode,
  }) async {
    try {
      // 发送请求
      final response = await _httpClient.put(
        '/labor-contracts/sign',
        queryParameters: {
          'contractCode': contractCode,
        },
      );
      
      // 解析响应数据
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      
      return apiResponse;
    } on DioException catch (e) {
      // 处理Dio异常
      final message = e.response?.data?['message'] ?? e.message ?? '网络请求失败';
      return ApiResponse<Map<String, dynamic>>(
        code: e.response?.statusCode ?? -1,
        message: message,
        data: null,
      );
    } catch (e) {
      // 处理其他异常
      return ApiResponse<Map<String, dynamic>>(
        code: -1,
        message: e.toString(),
        data: null,
      );
    }
  }
} 
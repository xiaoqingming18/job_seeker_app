import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/job_application_model.dart';
import 'http_client.dart';

/// 求职申请API服务
class JobApplicationApiService {
  final HttpClient _httpClient = HttpClient();
  
  /// 提交求职申请
  Future<ApiResponse<JobApplicationResponse>> submitJobApplication(
    JobApplicationRequest request
  ) async {
    try {
      // 发送请求
      final response = await _httpClient.post(
        '/api/job-seeker/applications',
        data: request.toJson(),
      );
      
      // 打印响应数据以进行调试
      print('申请职位API响应: ${response.data}');
      
      // 检查响应是否成功
      if (response.data != null && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        
        // 检查响应码
        final code = responseData['code'];
        if (code == 0) { // 通常0表示成功
          // 构造成功响应
          return ApiResponse<JobApplicationResponse>(
            code: 0,
            message: responseData['message'] as String? ?? 'success',
            data: responseData['data'] != null 
                ? JobApplicationResponse.fromJson(responseData['data'] as Map<String, dynamic>)
                : JobApplicationResponse(), // 如果没有详细数据，创建一个空对象
          );
        }
      }
      
      // 使用常规方式解析响应
      final apiResponse = ApiResponse<JobApplicationResponse>.fromJson(
        response.data,
        (json) {
          // 如果数据为null或不是Map，返回一个空的响应对象
          if (json == null || json is! Map<String, dynamic>) {
            return JobApplicationResponse();
          }
          return JobApplicationResponse.fromJson(json as Map<String, dynamic>);
        },
      );
      
      return apiResponse;
    } on DioException catch (e) {
      // 处理Dio异常
      print('DIO异常: ${e.toString()}');
      final message = e.response?.data?['message'] ?? e.message ?? '网络请求失败';
      return ApiResponse<JobApplicationResponse>(
        code: e.response?.statusCode ?? -1,
        message: message,
        data: null,
      );
    } catch (e) {
      // 处理其他异常
      print('提交申请时发生异常: $e');
      return ApiResponse<JobApplicationResponse>(
        code: -1,
        message: e.toString(),
        data: null,
      );
    }
  }
} 
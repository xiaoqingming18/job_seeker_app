import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/labor_demand_model.dart';
import 'http_client.dart';

/// 劳务需求API服务
class LaborDemandApiService {
  final HttpClient _httpClient = HttpClient();
  
  /// 获取劳务需求列表
  Future<ApiResponse<LaborDemandPageModel>> getLaborDemandList({
    required LaborDemandQuery query,
  }) async {
    try {
      // 发送请求
      final response = await _httpClient.post(
        '/labor-demand/list',
        data: query.toJson(),
      );
      
      // 解析响应数据
      final apiResponse = ApiResponse<LaborDemandPageModel>.fromJson(
        response.data,
        (json) => LaborDemandPageModel.fromJson(json as Map<String, dynamic>),
      );
      
      return apiResponse;
    } on DioException catch (e) {
      // 处理Dio异常
      final message = e.response?.data?['message'] ?? e.message ?? '网络请求失败';
      return ApiResponse<LaborDemandPageModel>(
        code: e.response?.statusCode ?? -1,
        message: message,
        data: null,
      );
    } catch (e) {
      // 处理其他异常
      return ApiResponse<LaborDemandPageModel>(
        code: -1,
        message: e.toString(),
        data: null,
      );
    }
  }
} 
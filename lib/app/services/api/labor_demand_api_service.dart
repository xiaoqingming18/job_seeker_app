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
  
  /// 获取劳务需求详情
  Future<ApiResponse<LaborDemandModel>> getLaborDemandDetail(int id) async {
    try {
      // 发送请求
      final response = await _httpClient.get(
        '/labor-demand/info/$id',
      );
      
      // 解析响应数据
      final apiResponse = ApiResponse<LaborDemandModel>.fromJson(
        response.data,
        (json) => LaborDemandModel.fromJson(json as Map<String, dynamic>),
      );
      
      return apiResponse;
    } on DioException catch (e) {
      // 处理Dio异常
      final message = e.response?.data?['message'] ?? e.message ?? '网络请求失败';
      return ApiResponse<LaborDemandModel>(
        code: e.response?.statusCode ?? -1,
        message: message,
        data: null,
      );
    } catch (e) {
      // 处理其他异常
      return ApiResponse<LaborDemandModel>(
        code: -1,
        message: e.toString(),
        data: null,
      );
    }
  }
  
  /// 按项目类型、工种类别和工种筛选劳务需求
  Future<ApiResponse<LaborDemandPageModel>> filterLaborDemands({
    String? projectType,
    int? categoryId,
    int? occupationId,
    int page = 1,
    int size = 10,
  }) async {
    try {
      // 构建查询参数
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      // 添加可选参数
      if (projectType != null) queryParams['projectType'] = projectType;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (occupationId != null) queryParams['occupationId'] = occupationId;
      
      // 发送GET请求
      final response = await _httpClient.get(
        '/labor-demand/filter',
        queryParameters: queryParams,
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
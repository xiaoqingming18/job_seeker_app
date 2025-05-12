import 'package:dio/dio.dart';
import 'package:job_seeker_app/app/models/api_response.dart';
import 'package:job_seeker_app/app/models/performance_model.dart';
import 'package:job_seeker_app/app/services/api/http_client.dart';

/// 绩效评估 API 服务
class PerformanceApiService {
  final HttpClient _httpClient = HttpClient();

  /// 获取分页绩效评估记录
  /// 
  /// 根据API文档，使用 `/api/performance/page` 接口获取分页列表
  /// 
  /// [queryParams] 查询参数，包括项目ID、成员ID、评估周期、分页信息等
  /// 
  /// 返回分页结果，包含绩效评估记录列表
  Future<ApiResponse<PerformancePageResult>> getPerformancePage(
      PerformanceQueryParams queryParams) async {
    try {
      print('获取绩效评估分页列表: ${queryParams.toJson()}');
      
      final response = await _httpClient.post(
        '/api/performance/page',
        data: queryParams.toJson(),
      );
      
      print('绩效评估分页列表响应: ${response.data}');
      
      return ApiResponse<PerformancePageResult>.fromJson(
        response.data,
        (json) => PerformancePageResult.fromJson(json),
      );
    } on DioException catch (e) {
      print('获取绩效评估列表Dio异常: ${e.message}, statusCode=${e.response?.statusCode}');
      // 处理Dio异常，封装为API响应格式
      return ApiResponse(
        code: e.response?.statusCode ?? -1,
        message: '网络错误：${e.message}',
        data: null,
      );
    } catch (e) {
      print('获取绩效评估列表异常: ${e.toString()}');
      return ApiResponse(
        code: -1,
        message: '处理异常：${e.toString()}',
        data: null,
      );
    }
  }

  /// 获取绩效评估详情
  /// 
  /// 根据API文档，使用 `/api/performance/info/{id}` 接口获取评估详情
  /// 
  /// [id] 绩效评估记录ID
  /// 
  /// 返回绩效评估详情
  Future<ApiResponse<PerformanceModel>> getPerformanceInfo(int id) async {
    try {
      print('获取绩效评估详情: id=$id');
      
      final response = await _httpClient.get('/api/performance/info/$id');
      
      print('绩效评估详情响应: ${response.data}');
      
      return ApiResponse<PerformanceModel>.fromJson(
        response.data,
        (json) => PerformanceModel.fromJson(json),
      );
    } on DioException catch (e) {
      print('获取绩效评估详情Dio异常: ${e.message}, statusCode=${e.response?.statusCode}');
      // 处理Dio异常，封装为API响应格式
      return ApiResponse(
        code: e.response?.statusCode ?? -1,
        message: '网络错误：${e.message}',
        data: null,
      );
    } catch (e) {
      print('获取绩效评估详情异常: ${e.toString()}');
      return ApiResponse(
        code: -1,
        message: '处理异常：${e.toString()}',
        data: null,
      );
    }
  }

  /// 获取成员的绩效评估记录列表
  /// 
  /// 根据API文档，使用 `/api/performance/list/member/{memberId}` 接口获取成员的评估记录
  /// 
  /// [memberId] 成员ID
  /// 
  /// 返回成员的绩效评估记录列表
  Future<ApiResponse<List<PerformanceModel>>> getMemberPerformanceList(
      int memberId) async {
    try {
      print('获取成员绩效评估列表: memberId=$memberId');
      
      final response = await _httpClient.get(
        '/api/performance/list/member/$memberId',
      );
      
      print('成员绩效评估列表响应: ${response.data}');
      
      return ApiResponse<List<PerformanceModel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => PerformanceModel.fromJson(item)).toList();
          }
          return [];
        },
      );
    } on DioException catch (e) {
      print('获取成员绩效评估列表Dio异常: ${e.message}, statusCode=${e.response?.statusCode}');
      // 处理Dio异常，封装为API响应格式
      return ApiResponse(
        code: e.response?.statusCode ?? -1,
        message: '网络错误：${e.message}',
        data: null,
      );
    } catch (e) {
      print('获取成员绩效评估列表异常: ${e.toString()}');
      return ApiResponse(
        code: -1,
        message: '处理异常：${e.toString()}',
        data: null,
      );
    }
  }

  /// 获取项目某评估周期的所有评估记录
  /// 
  /// 根据API文档，使用 `/api/performance/list/project/{projectId}/{period}` 接口
  /// 
  /// [projectId] 项目ID
  /// [period] 评估周期，如 "2023-06"
  /// 
  /// 返回项目某评估周期的所有评估记录
  Future<ApiResponse<List<PerformanceModel>>> getProjectPeriodPerformance(
      int projectId, String period) async {
    try {
      print('获取项目评估周期绩效列表: projectId=$projectId, period=$period');
      
      final response = await _httpClient.get(
        '/api/performance/list/project/$projectId/$period',
      );
      
      print('项目评估周期绩效列表响应: ${response.data}');
      
      return ApiResponse<List<PerformanceModel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => PerformanceModel.fromJson(item)).toList();
          }
          return [];
        },
      );
    } on DioException catch (e) {
      print('获取项目评估周期绩效列表Dio异常: ${e.message}, statusCode=${e.response?.statusCode}');
      // 处理Dio异常，封装为API响应格式
      return ApiResponse(
        code: e.response?.statusCode ?? -1,
        message: '网络错误：${e.message}',
        data: null,
      );
    } catch (e) {
      print('获取项目评估周期绩效列表异常: ${e.toString()}');
      return ApiResponse(
        code: -1,
        message: '处理异常：${e.toString()}',
        data: null,
      );
    }
  }
} 
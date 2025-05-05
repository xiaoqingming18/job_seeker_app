import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/occupation_model.dart';
import 'http_client.dart';

/// 工种API服务
class OccupationApiService {
  final HttpClient _httpClient = HttpClient();
  
  /// 获取热门工种列表
  Future<ApiResponse<List<OccupationModel>>> getHotOccupations({int limit = 6}) async {
    try {
      // 发送请求
      final response = await _httpClient.get(
        '/api/occupation/hot',
        queryParameters: {'limit': limit},
      );
      
      print('获取热门工种API响应: ${response.data}');
      
      // 检查响应是否成功
      if (response.data != null && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        
        // 检查响应码
        final code = responseData['code'];
        if (code == 0) { // 0表示成功
          // 解析数据
          final List<dynamic> jsonList = responseData['data'] as List<dynamic>;
          final List<OccupationModel> occupations = jsonList
              .map((item) => OccupationModel.fromJson(item as Map<String, dynamic>))
              .toList();
          
          // 打印工种图标URL，便于调试
          for (var occupation in occupations) {
            print('工种: ${occupation.name}, 图标URL: ${occupation.icon}');
          }
          
          return ApiResponse<List<OccupationModel>>(
            code: 0,
            message: 'success',
            data: occupations,
          );
        }
      }
      
      // 如果解析失败，返回错误
      return ApiResponse<List<OccupationModel>>(
        code: -1,
        message: '解析热门工种数据失败',
        data: null,
      );
    } on DioException catch (e) {
      // 处理Dio异常
      print('获取热门工种DIO异常: ${e.toString()}');
      final message = e.response?.data?['message'] ?? e.message ?? '网络请求失败';
      return ApiResponse<List<OccupationModel>>(
        code: e.response?.statusCode ?? -1,
        message: message,
        data: null,
      );
    } catch (e) {
      // 处理其他异常
      print('获取热门工种时发生异常: $e');
      return ApiResponse<List<OccupationModel>>(
        code: -1,
        message: e.toString(),
        data: null,
      );
    }
  }
} 
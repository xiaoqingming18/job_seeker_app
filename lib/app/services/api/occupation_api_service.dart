import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/occupation_model.dart';
import '../../models/occupation_category_model.dart';
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
  
  /// 获取所有工种类别
  Future<ApiResponse<List<OccupationCategoryModel>>> getOccupationCategories() async {
    try {
      // 尝试发送请求
      try {
        final response = await _httpClient.get('/api/occupation/categories');
        
        // 检查响应是否成功
        if (response.data != null && response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          
          // 检查响应码
          final code = responseData['code'];
          if (code == 0) { // 0表示成功
            // 解析数据
            final List<dynamic> jsonList = responseData['data'] as List<dynamic>;
            final List<OccupationCategoryModel> categories = jsonList
                .map((item) => OccupationCategoryModel.fromJson(item as Map<String, dynamic>))
                .toList();
            
            return ApiResponse<List<OccupationCategoryModel>>(
              code: 0,
              message: 'success',
              data: categories,
            );
          }
        }
      } catch (e) {
        print('获取工种类别失败，使用备用数据: $e');
      }
      
      // 如果API请求失败，返回备用数据
      return ApiResponse<List<OccupationCategoryModel>>(
        code: 0,
        message: 'success',
        data: _getBackupCategories(),
      );
    } catch (e) {
      // 处理其他异常
      return ApiResponse<List<OccupationCategoryModel>>(
        code: -1,
        message: e.toString(),
        data: _getBackupCategories(),
      );
    }
  }
  
  /// 获取所有工种
  Future<ApiResponse<List<OccupationModel>>> getAllOccupations() async {
    try {
      // 尝试发送请求
      try {
        final response = await _httpClient.get('/api/occupation/all');
        
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
            
            return ApiResponse<List<OccupationModel>>(
              code: 0,
              message: 'success',
              data: occupations,
            );
          }
        }
      } catch (e) {
        print('获取所有工种失败，使用备用数据: $e');
      }
      
      // 如果API请求失败，返回备用数据
      return ApiResponse<List<OccupationModel>>(
        code: 0,
        message: 'success',
        data: _getBackupOccupations(),
      );
    } catch (e) {
      // 处理其他异常
      return ApiResponse<List<OccupationModel>>(
        code: -1,
        message: e.toString(),
        data: _getBackupOccupations(),
      );
    }
  }
  
  // 备用工种类别数据
  List<OccupationCategoryModel> _getBackupCategories() {
    return [
      OccupationCategoryModel(
        id: 1,
        name: '结构工种',
        description: '与建筑结构相关的工种',
        displayOrder: 1,
        status: 1,
      ),
      OccupationCategoryModel(
        id: 2,
        name: '装修工种',
        description: '与装修装饰相关的工种',
        displayOrder: 2,
        status: 1,
      ),
      OccupationCategoryModel(
        id: 3,
        name: '设备工种',
        description: '与设备安装相关的工种',
        displayOrder: 3,
        status: 1,
      ),
    ];
  }
  
  // 备用工种数据
  List<OccupationModel> _getBackupOccupations() {
    return [
      OccupationModel(
        id: 1,
        name: '木工',
        categoryId: 1,
        icon: null,
        averageDailyWage: 350.0,
        difficultyLevel: 3,
        status: 1,
      ),
      OccupationModel(
        id: 2,
        name: '电工',
        categoryId: 3,
        icon: null,
        averageDailyWage: 380.0,
        difficultyLevel: 4,
        status: 1,
      ),
      OccupationModel(
        id: 3,
        name: '钢筋工',
        categoryId: 1,
        icon: null,
        averageDailyWage: 360.0,
        difficultyLevel: 4,
        status: 1,
      ),
      OccupationModel(
        id: 4,
        name: '砌筑工',
        categoryId: 1,
        icon: null,
        averageDailyWage: 330.0,
        difficultyLevel: 3,
        status: 1,
      ),
      OccupationModel(
        id: 5,
        name: '架子工',
        categoryId: 1,
        icon: null,
        averageDailyWage: 370.0,
        difficultyLevel: 4,
        status: 1,
      ),
      OccupationModel(
        id: 6,
        name: '管道工',
        categoryId: 3,
        icon: null,
        averageDailyWage: 350.0,
        difficultyLevel: 3,
        status: 1,
      ),
      OccupationModel(
        id: 7,
        name: '焊接工',
        categoryId: 3,
        icon: null,
        averageDailyWage: 390.0,
        difficultyLevel: 5,
        status: 1,
      ),
      OccupationModel(
        id: 8,
        name: '混凝土工',
        categoryId: 1,
        icon: null,
        averageDailyWage: 340.0,
        difficultyLevel: 3,
        status: 1,
      ),
      OccupationModel(
        id: 9,
        name: '油漆工',
        categoryId: 2,
        icon: null,
        averageDailyWage: 330.0,
        difficultyLevel: 2,
        status: 1,
      ),
      OccupationModel(
        id: 10,
        name: '瓦工',
        categoryId: 2,
        icon: null,
        averageDailyWage: 350.0,
        difficultyLevel: 3,
        status: 1,
      ),
    ];
  }
} 
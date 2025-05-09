import 'package:dio/dio.dart';
import 'package:job_seeker_app/app/models/api_response.dart';
import 'package:job_seeker_app/app/models/project_member_model.dart';
import 'package:job_seeker_app/app/services/api/http_client.dart';

/// 封装项目成员相关的API请求
class ProjectMemberApiService {
  final HttpClient _httpClient = HttpClient();

  /// 获取用户参与的项目列表
  /// 
  /// 根据API文档，调用 `/project/member/user/{userId}` 接口
  /// 
  /// [userId] 用户ID
  /// 
  /// 返回用户参与的所有项目列表
  Future<ApiResponse<List<ProjectMemberModel>>> getUserProjects(int userId) async {
    try {
      print('获取用户项目列表: userId=$userId');
      
      final response = await _httpClient.get('/project/member/user/$userId');
      
      print('项目列表响应: ${response.data}');
      
      return ApiResponse<List<ProjectMemberModel>>.fromJson(
        response.data,
        (json) {
          List<ProjectMemberModel> projects = [];
          
          if (json is List) {
            projects = json.map((item) => ProjectMemberModel.fromJson(item)).toList();
          } else if (json is Map<String, dynamic> && json['data'] is List) {
            // 处理嵌套在data字段中的数据
            projects = (json['data'] as List).map((item) => ProjectMemberModel.fromJson(item)).toList();
          }
          
          print('解析到${projects.length}个项目');
          return projects;
        },
      );
    } on DioException catch (e) {
      print('获取项目列表Dio异常: ${e.message}, statusCode=${e.response?.statusCode}');
      // 处理Dio异常，封装为API响应格式
      return ApiResponse(
        code: e.response?.statusCode ?? -1,
        message: '网络错误：${e.message}',
        data: null,
      );
    } catch (e) {
      print('获取项目列表异常: ${e.toString()}');
      return ApiResponse(
        code: -1,
        message: '处理异常：${e.toString()}',
        data: null,
      );
    }
  }
  
  /// 获取当前登录用户入职的项目ID（状态为active）
  /// 
  /// 根据API文档，调用 `/project/member/current-active-project` 接口
  /// 
  /// 返回当前用户入职的项目ID，如果未入职任何项目则返回null
  Future<ApiResponse<int?>> getCurrentUserActiveProject() async {
    try {
      print('获取当前用户入职项目ID');
      
      final response = await _httpClient.get('/project/member/current-active-project');
      
      print('当前用户入职项目ID响应: ${response.data}');
      
      return ApiResponse<int?>.fromJson(
        response.data,
        (json) => json is int ? json : null,
      );
    } on DioException catch (e) {
      print('获取当前用户入职项目ID Dio异常: ${e.message}, statusCode=${e.response?.statusCode}');
      // 处理Dio异常，封装为API响应格式
      return ApiResponse(
        code: e.response?.statusCode ?? -1,
        message: '网络错误：${e.message}',
        data: null,
      );
    } catch (e) {
      print('获取当前用户入职项目ID异常: ${e.toString()}');
      return ApiResponse(
        code: -1,
        message: '处理异常：${e.toString()}',
        data: null,
      );
    }
  }
} 
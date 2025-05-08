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
      final response = await _httpClient.get('/project/member/user/$userId');
      
      return ApiResponse<List<ProjectMemberModel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => ProjectMemberModel.fromJson(item)).toList();
          }
          return <ProjectMemberModel>[];
        },
      );
    } on DioException catch (e) {
      // 处理Dio异常，封装为API响应格式
      return ApiResponse(
        code: e.response?.statusCode ?? -1,
        message: '网络错误：${e.message}',
        data: null,
      );
    } catch (e) {
      // 处理其他异常，封装为API响应格式
      return ApiResponse(
        code: -1,
        message: '未知错误：$e',
        data: null,
      );
    }
  }
} 
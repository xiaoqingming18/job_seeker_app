import 'package:dio/dio.dart';
import '../../models/resume_model.dart';
import '../../models/api_response.dart';
import 'http_client.dart';

/// 简历管理API服务
class ResumeApiService {
  final HttpClient _client = HttpClient();

  /// 获取用户简历列表
  Future<ApiResponse<List<ResumeDTO>>> getResumeList() async {
    try {
      final response = await _client.get('/resume/list');
      final result = ApiResponse.fromJson(
        response.data,
        (data) => (data as List<dynamic>)
            .map((item) => ResumeDTO.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      return result;
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '获取简历列表失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 创建在线简历
  Future<ApiResponse<int>> createOnlineResume(
      Map<String, dynamic> resumeData) async {
    try {
      final response = await _client.post('/resume/online', data: resumeData);
      return ApiResponse.fromJson(
        response.data,
        (data) => data as int,
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '创建在线简历失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 创建附件简历
  Future<ApiResponse<int>> createAttachmentResume(
      Map<String, dynamic> resumeData) async {
    try {
      final response = await _client.post(
        '/resume/attachment',
        data: resumeData,
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as int,
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '创建附件简历失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 更新简历基本信息
  Future<ApiResponse<ResumeDTO>> updateResumeInfo(
      Map<String, dynamic> resumeData) async {
    try {
      final response = await _client.put('/resume/info', data: resumeData);
      return ApiResponse.fromJson(
        response.data,
        (data) => ResumeDTO.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '更新简历信息失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 更新在线简历
  Future<ApiResponse<int>> updateOnlineResume(
      Map<String, dynamic> resumeData) async {
    try {
      final response = await _client.put('/resume/online', data: resumeData);
      return ApiResponse.fromJson(
        response.data,
        (data) => data as int,
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '更新在线简历失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 删除简历
  Future<ApiResponse<bool>> deleteResume(int resumeId) async {
    try {
      final response = await _client.delete('/resume/$resumeId');
      return ApiResponse.fromJson(
        response.data,
        (data) => data as bool,
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '删除简历失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 获取在线简历详情
  Future<ApiResponse<OnlineResumeDTO>> getOnlineResumeDetail(int resumeId) async {
    try {
      final response = await _client.get('/resume/online/$resumeId');
      return ApiResponse.fromJson(
        response.data,
        (data) => OnlineResumeDTO.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '获取在线简历详情失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 获取附件简历详情
  Future<ApiResponse<AttachmentResumeDTO>> getAttachmentResumeDetail(
      int resumeId) async {
    try {
      final response = await _client.get('/resume/attachment/$resumeId');
      return ApiResponse.fromJson(
        response.data,
        (data) => AttachmentResumeDTO.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '获取附件简历详情失败: ${e.toString()}',
        data: null,
      );
    }
  }

  /// 设置默认简历
  Future<ApiResponse<bool>> setDefaultResume(int resumeId) async {
    try {
      final response = await _client.put('/resume/$resumeId/default');
      return ApiResponse.fromJson(
        response.data,
        (data) => data as bool,
      );
    } catch (e) {
      return ApiResponse(
        code: -1,
        message: '设置默认简历失败: ${e.toString()}',
        data: null,
      );
    }
  }
} 
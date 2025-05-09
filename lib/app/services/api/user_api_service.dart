import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/api_response.dart';
import '../../models/auth_model.dart';
import '../../models/user_model.dart';
import '../../models/avatar_upload_model.dart';
import 'http_client.dart';

/// 用户模块相关的 API 服务
class UserApiService {
  final HttpClient _httpClient = HttpClient();
  static const String _jobseekerProfileKey = 'jobseeker_profile'; // 存储求职者资料的键名

  /// 管理员登录
  Future<ApiResponse<AuthModel>> adminLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/user/admin-login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return ApiResponse<AuthModel>.fromJson(
        response.data,
        (json) => AuthModel.fromJson(json),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<AuthModel>(
        code: 500,
        message: '登录失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 求职者登录
  Future<ApiResponse<AuthModel>> jobseekerLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/user/jobseeker-login',
        data: {
          'username': username,
          'password': password,
        },
      );
      final apiResponse = ApiResponse<AuthModel>.fromJson(
        response.data,
        (json) => AuthModel.fromJson(json),
      );
      
      // 如果登录成功，保存令牌
      if (apiResponse.isSuccess && apiResponse.data != null) {
        await _httpClient.saveToken(apiResponse.data!.token);
        
        // 登录成功后，获取并缓存求职者资料
        final profileResponse = await fetchAndCacheJobseekerProfile();
        
        // 如果成功获取到用户资料，保存用户ID
        if (profileResponse.isSuccess && profileResponse.data != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', profileResponse.data!.userId ?? 0);
        }
      }
      
      return apiResponse;
    } catch (e) {
      // 处理错误
      return ApiResponse<AuthModel>(
        code: 500,
        message: '登录失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 企业管理员登录
  Future<ApiResponse<AuthModel>> companyAdminLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/user/company-admin-login',
        data: {
          'username': username,
          'password': password,
        },
      );
      final apiResponse = ApiResponse<AuthModel>.fromJson(
        response.data,
        (json) => AuthModel.fromJson(json),
      );
      
      // 如果登录成功，保存令牌
      if (apiResponse.isSuccess && apiResponse.data != null) {
        await _httpClient.saveToken(apiResponse.data!.token);
      }
      
      return apiResponse;
    } catch (e) {
      // 处理错误
      return ApiResponse<AuthModel>(
        code: 500,
        message: '登录失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 项目经理登录
  Future<ApiResponse<AuthModel>> projectManagerLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '/user/project-manager-login',
        data: {
          'username': username,
          'password': password,
        },
      );
      final apiResponse = ApiResponse<AuthModel>.fromJson(
        response.data,
        (json) => AuthModel.fromJson(json),
      );
      
      // 如果登录成功，保存令牌
      if (apiResponse.isSuccess && apiResponse.data != null) {
        await _httpClient.saveToken(apiResponse.data!.token);
      }
      
      return apiResponse;
    } catch (e) {
      // 处理错误
      return ApiResponse<AuthModel>(
        code: 500,
        message: '登录失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 求职者注册
  Future<ApiResponse<String>> jobseekerRegister({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      final response = await _httpClient.post(
        '/user/jobseeker-register',
        data: {
          'username': username,
          'password': password,
          'email': email,
        },
      );
      
      // 直接返回ApiResponse，不再期望返回token
      return ApiResponse<String>(
        code: response.data['code'] as int,
        message: response.data['message'] as String,
        data: null, // 注册接口不需要返回数据
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<String>(
        code: 500,
        message: '注册失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 更新求职者个人信息
  Future<ApiResponse<UserModel>> updateJobseekerInfo({
    String? mobile,
    String? email,
    String? avatar,
    String? realName,
    String? gender,
    String? birthday,
    String? expectPosition,
    int? workYears,
    String? skill,
    String? certificates,
    String? resumeUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (mobile != null) data['mobile'] = mobile;
      if (email != null) data['email'] = email;
      if (avatar != null) data['avatar'] = avatar;
      if (realName != null) data['realName'] = realName;
      if (gender != null) data['gender'] = gender;
      if (birthday != null) data['birthday'] = birthday;
      if (expectPosition != null) data['expectPosition'] = expectPosition;
      if (workYears != null) data['workYears'] = workYears;
      if (skill != null) data['skill'] = skill;
      if (certificates != null) data['certificates'] = certificates;
      if (resumeUrl != null) data['resumeUrl'] = resumeUrl;
      
      final response = await _httpClient.post(
        '/user/jobseeker-update-info',
        data: data,
      );
      
      return ApiResponse<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<UserModel>(
        code: 500,
        message: '更新个人信息失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 获取求职者个人资料
  Future<ApiResponse<UserModel>> getJobseekerProfile() async {
    try {
      final response = await _httpClient.get('/user/jobseeker-profile');
      
      return ApiResponse<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<UserModel>(
        code: 500,
        message: '获取个人资料失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 修改求职者密码
  Future<ApiResponse<String>> updateJobseekerPassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _httpClient.post(
        '/user/jobseeker-update-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      
      return ApiResponse<String>.fromJson(
        response.data,
        (json) => json.toString(),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<String>(
        code: 500,
        message: '修改密码失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }
  
  /// 登出 - 清除本地令牌
  Future<void> logout() async {
    await _httpClient.clearToken();
  }

  /// 验证令牌有效性
  Future<ApiResponse<TokenVerificationResponse>> verifyToken() async {
    try {
      final response = await _httpClient.get('/user/verify-token');
      
      final apiResponse = ApiResponse<TokenVerificationResponse>.fromJson(
        response.data,
        (data) => TokenVerificationResponse.fromJson(data),
      );
      
      // 如果验证成功，保存用户ID
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', apiResponse.data!.userId);
        
        // 由于验证成功，尝试获取并缓存最新的用户资料
        fetchAndCacheJobseekerProfile();
      }
      
      return apiResponse;
    } catch (e) {
      // 处理错误
      return ApiResponse<TokenVerificationResponse>(
        code: 500,
        message: '验证令牌失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 获取并缓存求职者个人资料
  Future<ApiResponse<UserModel>> fetchAndCacheJobseekerProfile() async {
    try {
      final response = await _httpClient.get('/user/jobseeker-profile');
      final apiResponse = ApiResponse<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );
      
      // 如果获取资料成功，缓存到本地存储
      if (apiResponse.isSuccess && apiResponse.data != null) {
        // 缓存用户资料
        await _cacheJobseekerProfile(apiResponse.data!);
        
        // 同时保存用户ID到单独的键
        if (apiResponse.data!.userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', apiResponse.data!.userId!);
          print('已保存用户ID: ${apiResponse.data!.userId}');
        } else {
          print('警告: 获取到的用户资料中没有userId字段');
        }
      }
      
      return apiResponse;
    } catch (e) {
      // 处理错误
      print('获取个人资料失败: ${e is DioException ? e.message : e.toString()}');
      return ApiResponse<UserModel>(
        code: 500,
        message: '获取个人资料失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 从缓存中获取求职者资料
  Future<UserModel?> getCachedJobseekerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString(_jobseekerProfileKey);
      
      if (profileJson != null && profileJson.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(profileJson));
      }
      return null;
    } catch (e) {
      print('获取缓存的求职者资料失败: $e');
      return null;
    }
  }

  /// 缓存求职者资料到本地存储
  Future<void> _cacheJobseekerProfile(UserModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jobseekerProfileKey, jsonEncode(profile.toJson()));
    } catch (e) {
      print('缓存求职者资料失败: $e');
    }
  }

  /// 清除缓存的求职者资料
  Future<void> clearCachedJobseekerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jobseekerProfileKey);
    } catch (e) {
      print('清除缓存的求职者资料失败: $e');
    }
  }

  /// 上传头像
  Future<ApiResponse<AvatarUploadModel>> uploadAvatar({
    required File file,
  }) async {
    try {
      // 验证文件是否是图片
      final String fileName = file.path.split('/').last;
      final String extension = fileName.split('.').last.toLowerCase();
      
      // 检查文件扩展名是否为常见图片格式
      final List<String> validImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
      if (!validImageExtensions.contains(extension)) {
        return ApiResponse<AvatarUploadModel>(
          code: 400,
          message: '只能选择图片文件（JPG, PNG, GIF, BMP, WEBP）',
        );
      }
      
      // 根据扩展名设置正确的MIME类型
      String mimeType = 'image/jpeg'; // 默认MIME类型
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'bmp':
          mimeType = 'image/bmp';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
      }
      
      // 创建FormData对象，带上正确的MIME类型
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType), // 设置内容类型
        ),
      });
      
      // 发送POST请求，上传文件
      final response = await _httpClient.post(
        '/file/upload/avatar',
        data: formData,
      );
      
      // 解析响应数据
      return ApiResponse<AvatarUploadModel>.fromJson(
        response.data,
        (json) => AvatarUploadModel.fromJson(json),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<AvatarUploadModel>(
        code: 500,
        message: '上传头像失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }
}

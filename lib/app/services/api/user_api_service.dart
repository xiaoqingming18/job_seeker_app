import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/api_response.dart';
import '../../models/auth_model.dart';
import '../../models/user_model.dart';
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
        await fetchAndCacheJobseekerProfile();
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
  Future<ApiResponse<AuthModel>> jobseekerRegister({
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
      final apiResponse = ApiResponse<AuthModel>.fromJson(
        response.data,
        (json) => AuthModel.fromJson(json),
      );
      
      // 如果注册成功，保存令牌
      if (apiResponse.isSuccess && apiResponse.data != null) {
        await _httpClient.saveToken(apiResponse.data!.token);
      }
      
      return apiResponse;
    } catch (e) {
      // 处理错误
      return ApiResponse<AuthModel>(
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
      
      return ApiResponse<TokenVerificationResponse>.fromJson(
        response.data,
        (data) => TokenVerificationResponse.fromJson(data),
      );
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
        await _cacheJobseekerProfile(apiResponse.data!);
      }
      
      return apiResponse;
    } catch (e) {
      // 处理错误
      return ApiResponse<UserModel>(
        code: 500,
        message: '获取个人资料失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }  /// 从缓存中获取求职者资料
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
}

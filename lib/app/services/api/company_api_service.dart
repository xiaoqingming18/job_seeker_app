import 'package:dio/dio.dart';

import '../../models/api_response.dart';
import '../../models/company_model.dart';
import 'http_client.dart';

/// 企业模块相关的 API 服务
class CompanyApiService {
  final HttpClient _httpClient = HttpClient();

  /// 注册新企业及管理员
  Future<ApiResponse<String>> registerCompany({
    required String name,
    required String licenseNumber,
    required String legalPerson,
    required String username,
    required String password,
    required String email,
    String? address,
    String? position,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'licenseNumber': licenseNumber,
        'legalPerson': legalPerson,
        'username': username,
        'password': password,
        'email': email,
      };
      
      if (address != null) data['address'] = address;
      if (position != null) data['position'] = position;
      
      final response = await _httpClient.post(
        '/company/register',
        data: data,
      );
      
      return ApiResponse<String>.fromJson(
        response.data,
        (json) => json.toString(),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<String>(
        code: 500,
        message: '注册企业失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 获取企业信息
  Future<ApiResponse<CompanyModel>> getCompanyInfo(int id) async {
    try {
      final response = await _httpClient.get('/company/info/$id');
      
      return ApiResponse<CompanyModel>.fromJson(
        response.data,
        (json) => CompanyModel.fromJson(json),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<CompanyModel>(
        code: 500,
        message: '获取企业信息失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 更新企业信息
  Future<ApiResponse<CompanyModel>> updateCompanyInfo({
    required int id,
    String? name,
    String? address,
    String? legalPerson,
  }) async {
    try {
      final Map<String, dynamic> data = {'id': id};
      if (name != null) data['name'] = name;
      if (address != null) data['address'] = address;
      if (legalPerson != null) data['legalPerson'] = legalPerson;
      
      final response = await _httpClient.put(
        '/company/update',
        data: data,
      );
      
      return ApiResponse<CompanyModel>.fromJson(
        response.data,
        (json) => CompanyModel.fromJson(json),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<CompanyModel>(
        code: 500,
        message: '更新企业信息失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }

  /// 添加项目经理
  Future<ApiResponse<String>> addProjectManager({
    required int companyId,
    required String username,
    required String password,
    required String email,
    String? position,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'companyId': companyId,
        'username': username,
        'password': password,
        'email': email,
      };
      
      if (position != null) data['position'] = position;
      
      final response = await _httpClient.post(
        '/company/add-project-manager',
        data: data,
      );
      
      return ApiResponse<String>.fromJson(
        response.data,
        (json) => json.toString(),
      );
    } catch (e) {
      // 处理错误
      return ApiResponse<String>(
        code: 500,
        message: '添加项目经理失败: ${e is DioException ? e.message : e.toString()}',
      );
    }
  }
}

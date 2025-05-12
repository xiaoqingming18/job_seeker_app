import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:job_seeker_app/app/services/api/http_client.dart';

/// 工资相关的API服务
class SalaryApiService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  /// 获取个人工资列表
  /// [current] 当前页码，默认为1
  /// [size] 每页数量，默认为10
  Future<Map<String, dynamic>> getPersonalSalaryList({
    int current = 1,
    int size = 10,
  }) async {
    try {
      final dio.Response response = await _httpClient.get(
        '/salary/personal/list',
        queryParameters: {
          'current': current,
          'size': size,
        },
      );
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// 获取工资详情
  /// [id] 工资单ID
  Future<Map<String, dynamic>> getSalaryDetail(int id) async {
    try {
      final dio.Response response = await _httpClient.get('/salary/$id');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }
} 
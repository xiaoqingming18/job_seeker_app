import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/api_response.dart';
import 'package:job_seeker_app/app/models/attendance_model.dart';
import 'package:job_seeker_app/app/models/attendance_statistics_model.dart';
import 'package:job_seeker_app/app/services/api/http_client.dart';

/// 考勤 API 服务
class AttendanceApiService {
  final HttpClient _httpClient = HttpClient();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// 签到
  Future<ApiResponse<AttendanceModel>> checkIn({
    required int projectId,
    String? location,
    String? remarks,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/attendance/check-in',
        data: {
          'projectId': projectId,
          'location': location,
          'remarks': remarks,
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => AttendanceModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 签退
  Future<ApiResponse<AttendanceModel>> checkOut({
    required int projectId,
    String? location,
    String? remarks,
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/attendance/check-out',
        data: {
          'projectId': projectId,
          'location': location,
          'remarks': remarks,
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => AttendanceModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 获取个人考勤记录
  Future<ApiResponse<Map<String, dynamic>>> getMyAttendanceRecords({
    int? projectId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int size = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };

      if (projectId != null) {
        queryParams['projectId'] = projectId;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (startDate != null) {
        queryParams['startDate'] = _dateFormat.format(startDate);
      }

      if (endDate != null) {
        queryParams['endDate'] = _dateFormat.format(endDate);
      }

      final response = await _httpClient.get(
        '/api/attendance/my-records',
        queryParameters: queryParams,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) {
          // 解析分页数据
          final Map<String, dynamic> result = {};
          
          if (json is Map<String, dynamic>) {
            // 解析记录数据
            if (json['records'] != null) {
              result['records'] = (json['records'] as List)
                  .map((item) => AttendanceModel.fromJson(item))
                  .toList();
            } else {
              result['records'] = <AttendanceModel>[];
            }
            
            // 解析分页信息
            result['total'] = json['total'] ?? 0;
            result['size'] = json['size'] ?? 10;
            result['current'] = json['current'] ?? 1;
            result['pages'] = json['pages'] ?? 0;
          }
          
          return result;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 获取个人考勤统计
  Future<ApiResponse<AttendanceStatisticsModel>> getMyAttendanceStatistics({
    DateTime? startDate,
    DateTime? endDate,
    int? projectId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['startDate'] = _dateFormat.format(startDate);
      }

      if (endDate != null) {
        queryParams['endDate'] = _dateFormat.format(endDate);
      }

      if (projectId != null) {
        queryParams['projectId'] = projectId;
      }

      final response = await _httpClient.get(
        '/api/attendance/statistics/my',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => AttendanceStatisticsModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
} 
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/api_response.dart';
import 'package:job_seeker_app/app/models/leave_model.dart';
import 'package:job_seeker_app/app/services/api/http_client.dart';

/// 请假 API 服务
class LeaveApiService {
  final HttpClient _httpClient = HttpClient();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// 提交请假申请
  Future<ApiResponse<LeaveModel>> submitLeaveRequest(LeaveRequestModel request) async {
    try {
      // 准备请求数据
      final Map<String, dynamic> data = {
        'projectId': request.projectId,
        'leaveType': request.type.toString().split('.').last,
        'startDate': _dateFormat.format(request.startTime),
        'endDate': _dateFormat.format(request.endTime),
        'reason': request.reason,
        'totalDays': _calculateDays(request.startTime, request.endTime),
      };

      // 如果有附件，则添加附件
      if (request.attachments != null && request.attachments!.isNotEmpty) {
        data['attachments'] = request.attachments;
      }

      // 发送请求
      final response = await _httpClient.post(
        '/api/leave/apply',
        data: data,
      );

      // 解析响应
      return ApiResponse.fromJson(
        response.data,
        (json) => LeaveModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 计算请假天数
  double _calculateDays(DateTime startTime, DateTime endTime) {
    // 简单计算日期差，包含起止日期
    return endTime.difference(startTime).inDays + 1.0;
  }

  /// 获取请假申请列表
  /// 
  /// 完全重写以直接处理后端API返回的特定结构
  Future<ApiResponse<Map<String, dynamic>>> getMyLeaveRecords({
    int? projectId,
    LeaveStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int size = 10,
  }) async {
    try {
      // 准备查询参数
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };

      if (projectId != null && projectId > 0) {
        queryParams['projectId'] = projectId;
      }

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      if (startDate != null) {
        queryParams['startDate'] = _dateFormat.format(startDate);
      }

      if (endDate != null) {
        queryParams['endDate'] = _dateFormat.format(endDate);
      }

      print('请假API请求参数: $queryParams');

      // 发送请求
      final response = await _httpClient.get(
        '/api/leave/my-leaves',
        queryParameters: queryParams,
      );

      print('请假API原始响应: ${response.data}');

      // 准备默认的空结果
      final defaultResult = {
        'records': <LeaveModel>[],
        'total': 0,
        'size': size,
        'current': page,
        'pages': 1
      };

      // Step 1: 验证响应格式
      if (response.data == null) {
        print('请假API错误: 响应为空');
        return ApiResponse(
          code: -1,
          message: '响应为空',
          data: defaultResult,
        );
      }

      // Step 2: 确保响应是Map类型
      if (response.data is! Map<String, dynamic>) {
        print('请假API错误: 响应不是有效的JSON对象');
        return ApiResponse(
          code: -1,
          message: '响应格式错误',
          data: defaultResult,
        );
      }

      final responseMap = response.data as Map<String, dynamic>;
      
      // Step 3: 提取状态码和消息
      final code = responseMap['code'] is int ? responseMap['code'] as int : -1;
      final message = responseMap['message'] is String ? responseMap['message'] as String : '未知错误';
      
      // Step 4: 非成功状态直接返回错误
      if (code != 0) {
        print('请假API错误: code=$code, message=$message');
        return ApiResponse(
          code: code,
          message: message,
          data: defaultResult,
        );
      }
      
      // Step 5: 提取数据部分
      final data = responseMap['data'];
      
      // Step 6: 特殊情况处理 - 如果data为null或不是Map类型
      if (data == null) {
        print('请假API警告: 数据部分为空');
        return ApiResponse(
          code: 0,
          message: 'success',
          data: defaultResult,
        );
      }
      
      if (data is! Map<String, dynamic>) {
        print('请假API警告: 数据部分不是JSON对象');
        
        // 特殊情况: 如果data是List类型，可能是直接返回了记录列表
        if (data is List) {
          print('请假API特殊情况: 数据是记录列表');
          final List<LeaveModel> records = [];
          
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              try {
                records.add(LeaveModel.fromJson(item));
              } catch (e) {
                print('请假记录解析错误: $e');
              }
            }
          }
          
          return ApiResponse(
            code: 0,
            message: 'success',
            data: {
              'records': records,
              'total': records.length,
              'size': size,
              'current': page,
              'pages': 1
            },
          );
        }
        
        return ApiResponse(
          code: 0,
          message: 'success',
          data: defaultResult,
        );
      }
      
      final dataMap = data as Map<String, dynamic>;
      
      // Step 7: 提取分页信息
      final currentPage = dataMap['current'] is int ? dataMap['current'] as int : page;
      final pageSize = dataMap['size'] is int ? dataMap['size'] as int : size;
      int pages = 1;
      
      if (dataMap['pages'] != null) {
        if (dataMap['pages'] is int) {
          pages = (dataMap['pages'] as int) > 0 ? (dataMap['pages'] as int) : 1;
        } else if (dataMap['pages'] is String) {
          pages = int.tryParse(dataMap['pages'] as String) ?? 1;
          pages = pages > 0 ? pages : 1;
        }
      }
      
      // Step 8: 提取记录列表
      final List<LeaveModel> records = [];
      
      // 尝试提取records字段
      final recordsData = dataMap['records'];
      if (recordsData is List) {
        for (final item in recordsData) {
          if (item is Map<String, dynamic>) {
            try {
              records.add(LeaveModel.fromJson(item));
            } catch (e) {
              print('请假记录解析错误: $e');
            }
          }
        }
      } else {
        print('请假API警告: records字段不是List类型或不存在');
        
        // 如果没有records字段，尝试其他可能的字段
        final alternativeFields = ['data', 'items', 'list', 'content'];
        
        for (final field in alternativeFields) {
          if (dataMap[field] is List) {
            print('请假API: 尝试从$field字段提取记录');
            final items = dataMap[field] as List;
            for (final item in items) {
              if (item is Map<String, dynamic>) {
                try {
                  records.add(LeaveModel.fromJson(item));
                } catch (e) {
                  print('请假记录解析错误: $e');
                }
              }
            }
            break;
          }
        }
      }
      
      // Step 9: 提取total字段，如果没有或无效，使用records长度
      int total = records.length;
      if (dataMap['total'] != null) {
        if (dataMap['total'] is int) {
          total = dataMap['total'] as int;
        } else if (dataMap['total'] is String) {
          total = int.tryParse(dataMap['total'] as String) ?? records.length;
        }
      }
      
      // 确保total至少等于records的长度
      if (total < records.length) {
        print('请假API警告: total值($total)小于实际记录数(${records.length})，使用记录数作为total');
        total = records.length;
      }
      
      // Step 10: 构建结果
      print('请假API成功解析: ${records.length}条记录');
      
      final result = {
        'records': records,
        'total': total,
        'size': pageSize,
        'current': currentPage,
        'pages': pages,
      };
      
      return ApiResponse(
        code: 0,
        message: 'success',
        data: result,
      );
    } catch (e, stackTrace) {
      print('请假API异常: ${e.toString()}');
      print('堆栈跟踪: $stackTrace');
      
      return ApiResponse(
        code: -1,
        message: '请求异常: ${e.toString()}',
        data: {
          'records': <LeaveModel>[],
          'total': 0,
          'size': size,
          'current': page,
          'pages': 1
        },
      );
    }
  }

  /// 获取请假申请详情
  Future<ApiResponse<LeaveModel>> getLeaveDetail(int leaveId) async {
    try {
      final response = await _httpClient.get('/api/leave/$leaveId');

      return ApiResponse.fromJson(
        response.data,
        (json) => LeaveModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 取消请假申请
  Future<ApiResponse<bool>> cancelLeaveRequest(int leaveId) async {
    try {
      final response = await _httpClient.post(
        '/api/leave/cancel',
        data: {'leaveId': leaveId},
      );

      return ApiResponse<bool>.fromJson(
        response.data,
        (json) => json == true,
      );
    } catch (e) {
      rethrow;
    }
  }
} 
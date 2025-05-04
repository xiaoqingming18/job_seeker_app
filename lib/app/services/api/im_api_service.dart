import 'package:dio/dio.dart';
import 'http_client.dart';

/// IM API服务类
/// 提供即时通讯相关的API接口
class ImApiService {
  final HttpClient _httpClient = HttpClient();
  
  /// 获取用户的所有会话
  /// [userId] 用户ID
  Future<List<Map<String, dynamic>>> getUserConversations(int userId) async {
    try {
      final response = await _httpClient.get('/api/im/conversations/user/$userId');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['code'] == 0 && responseData['message'] == 'success') {
          return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else {
          throw Exception('获取会话列表失败: ${responseData['message']}');
        }
      } else {
        throw Exception('获取会话列表请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    } catch (e) {
      throw Exception('获取会话列表异常: $e');
    }
  }
  
  /// 获取会话详情
  /// [conversationId] 会话ID
  Future<Map<String, dynamic>> getConversationDetail(int conversationId) async {
    try {
      final response = await _httpClient.get('/api/im/conversations/$conversationId');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['code'] == 0 && responseData['message'] == 'success') {
          return Map<String, dynamic>.from(responseData['data'] ?? {});
        } else {
          throw Exception('获取会话详情失败: ${responseData['message']}');
        }
      } else {
        throw Exception('获取会话详情请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    } catch (e) {
      throw Exception('获取会话详情异常: $e');
    }
  }
  
  /// 获取会话成员列表
  /// [conversationId] 会话ID
  Future<List<Map<String, dynamic>>> getConversationMembers(int conversationId) async {
    try {
      final response = await _httpClient.get('/api/im/conversations/$conversationId/members');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['code'] == 0 && responseData['message'] == 'success') {
          return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else {
          throw Exception('获取会话成员失败: ${responseData['message']}');
        }
      } else {
        throw Exception('获取会话成员请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    } catch (e) {
      throw Exception('获取会话成员异常: $e');
    }
  }
  
  /// 获取会话消息列表
  /// [conversationId] 会话ID
  /// [page] 页码
  /// [size] 每页大小
  Future<List<Map<String, dynamic>>> getConversationMessages(
    int conversationId, {
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _httpClient.get(
        '/api/im/conversations/$conversationId/messages',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['code'] == 0 && responseData['message'] == 'success') {
          return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else {
          throw Exception('获取会话消息失败: ${responseData['message']}');
        }
      } else {
        throw Exception('获取会话消息请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    } catch (e) {
      throw Exception('获取会话消息异常: $e');
    }
  }
  
  /// 发送消息
  /// [conversationId] 会话ID
  /// [senderId] 发送者ID
  /// [content] 消息内容
  /// [messageType] 消息类型，默认为text
  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required int senderId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final response = await _httpClient.post(
        '/api/im/messages/send',
        data: {
          'conversationId': conversationId,
          'senderId': senderId,
          'content': content,
          'messageType': messageType,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        if (responseData['code'] == 0 && responseData['message'] == 'success') {
          return Map<String, dynamic>.from(responseData['data'] ?? {});
        } else {
          throw Exception('发送消息失败: ${responseData['message']}');
        }
      } else {
        throw Exception('发送消息请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    } catch (e) {
      throw Exception('发送消息异常: $e');
    }
  }
  
  /// 标记会话已读
  /// [conversationId] 会话ID
  /// [userId] 用户ID
  Future<bool> markConversationAsRead(int conversationId, int userId) async {
    try {
      final response = await _httpClient.put(
        '/api/im/conversations/$conversationId/read',
        data: {
          'userId': userId,
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['code'] == 0 && responseData['message'] == 'success') {
          return true;
        } else {
          throw Exception('标记已读失败: ${responseData['message']}');
        }
      } else {
        throw Exception('标记已读请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    } catch (e) {
      throw Exception('标记已读异常: $e');
    }
  }
} 
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP 客户端封装类，处理请求、响应和错误
class HttpClient {
  static const String _baseUrl = 'http://192.168.137.1:8080';
  static const int _connectTimeout = 15000; // 连接超时时间（毫秒）
  static const int _receiveTimeout = 15000; // 接收超时时间（毫秒）
  static const String _storageTokenKey = 'auth_token'; // 存储 token 的键名

  late Dio _dio;
  static final HttpClient _instance = HttpClient._internal();

  /// 单例模式获取实例
  factory HttpClient() => _instance;

  /// 内部构造函数
  HttpClient._internal() {
    final BaseOptions options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(milliseconds: _connectTimeout),
      receiveTimeout: Duration(milliseconds: _receiveTimeout),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      },
      responseType: ResponseType.json,
    );
    
    _dio = Dio(options);
    _setupInterceptors();
  }

  /// 设置拦截器
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          // 在每个请求头中添加 token
          final String? token = await _getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          // 可以在这里统一处理响应
          return handler.next(response);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          // 错误处理
          if (e.response?.statusCode == 401) {
            // 处理未授权错误（令牌过期等）
            // TODO: 实现令牌刷新或重定向到登录页面
          }
          return handler.next(e);
        },
      ),
    );

    // 添加日志拦截器（仅在调试模式下）
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  /// 从本地存储获取令牌
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageTokenKey);
  }

  /// 将令牌保存到本地存储
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageTokenKey, token);
  }

  /// 清除本地存储的令牌
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageTokenKey);
  }

  /// GET 请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST 请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT 请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE 请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

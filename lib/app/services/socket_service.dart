import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';  // 添加定时器支持

/// Socket.IO 服务，管理 WebSocket 连接
class SocketService extends GetxService {
  // localhost 在模拟器/真机上不是指向开发机器，需要使用实际IP地址
  // 对于真机测试，请使用开发机器的实际IP地址
  static const String _serverUrl = 'http://192.168.200.60:9092'; // 使用实际IP地址替代localhost
  static const String _storageTokenKey = 'auth_token';
  
  IO.Socket? _socket;
  final Rx<bool> isConnected = false.obs;

  // 添加心跳检测定时器
  Timer? _heartbeatTimer;
  
  /// 获取 Socket 实例
  IO.Socket? get socket => _socket;

  /// 初始化 Socket 连接
  Future<SocketService> init() async {
    // 首次初始化时尝试连接
    await connect();
    
    // 设置定期检查连接状态的定时器
    _startHeartbeat();
    
    return this;
  }

  /// 开始心跳检测
  void _startHeartbeat() {
    // 取消可能存在的旧定时器
    _heartbeatTimer?.cancel();
    
    // 每30秒检查一次连接状态
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_socket == null || !_socket!.connected) {
        print('WebSocket心跳检测：连接已断开，尝试重连...');
        connect();
      } else {
        print('WebSocket心跳检测：连接正常，Socket ID: ${_socket?.id}');
        
        // 发送心跳消息，保持连接活跃
        _socket?.emit('heartbeat', {'time': DateTime.now().toIso8601String()});
      }
    });
  }

  /// 连接到 WebSocket 服务器
  Future<void> connect() async {
    try {
      // 获取令牌
      final String? token = await _getToken();
      
      if (token == null || token.isEmpty) {
        print('没有可用的令牌，无法连接 WebSocket');
        return;
      }

      // 断开可能存在的旧连接
      disconnect();
      
      print('尝试连接WebSocket服务器: $_serverUrl');
      print('使用Token: ${token.length > 10 ? "${token.substring(0, 10)}..." : token}');
      
      // 使用与测试网页相似的配置，但适配 socket_io_client 1.0.2 API
      _socket = IO.io(_serverUrl, {
        'transports': ['websocket', 'polling'], // 同时支持websocket和polling
        'query': {'token': token}, // 通过query参数传递token
        'autoConnect': true, // 启用自动连接
        'forceNew': true, // 强制创建新连接
        'timeout': 20000, // 增加超时时间到20秒
        'reconnection': true, // 启用重连
        'reconnectionAttempts': 5, // 设置重连尝试次数
        'reconnectionDelay': 1000, // 重连延迟1秒
        'reconnectionDelayMax': 5000, // 最大重连延迟5秒
      });

      // 设置事件处理
      _setupEventHandlers();
      
      // 打印连接状态
      print('WebSocket 连接已初始化，Socket状态: ${_socket?.connected}');
    } catch (e) {
      print('Socket.IO 连接失败: $e');
      if (kDebugMode) {
        print('Stack trace: ${StackTrace.current}');
      }
    }
  }

  /// 断开 WebSocket 连接
  void disconnect() {
    if (_socket != null) {
      print('断开现有 WebSocket 连接');
      if (_socket!.connected) {
        _socket!.disconnect();
      }
      _socket = null;
      isConnected.value = false;
    }
    
    // 同时取消心跳定时器
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 设置事件处理器
  void _setupEventHandlers() {
    _socket?.on('connect', (_) {
      print('Socket.IO 连接成功，ID: ${_socket?.id}');
      isConnected.value = true;
      
      // 不再在这里直接订阅合同通知事件，避免重复订阅
      // NotificationService 已经通过 on() 方法订阅了此事件
    });

    _socket?.on('connecting', (_) {
      print('Socket.IO 正在连接...');
    });

    _socket?.on('disconnect', (_) {
      print('Socket.IO 断开连接');
      isConnected.value = false;
    });

    _socket?.on('connect_error', (error) {
      print('Socket.IO 连接错误: $error');
      isConnected.value = false;
    });

    _socket?.on('connect_timeout', (_) {
      print('Socket.IO 连接超时');
      isConnected.value = false;
    });

    _socket?.on('error', (error) {
      print('Socket.IO 错误: $error');
    });

    _socket?.on('reconnect', (attempt) {
      print('Socket.IO 重新连接成功，尝试次数: $attempt');
      isConnected.value = true;
      
      // 同样不在这里重新订阅
    });

    _socket?.on('reconnecting', (attempt) {
      print('Socket.IO 正在尝试重新连接，尝试次数: $attempt');
    });

    _socket?.on('reconnect_error', (error) {
      print('Socket.IO 重连错误: $error');
    });

    _socket?.on('reconnect_failed', (_) {
      print('Socket.IO 重连失败，达到最大尝试次数');
    });
  }

  /// 从本地存储获取令牌
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_storageTokenKey);
      return token;
    } catch (e) {
      print('获取令牌失败: $e');
      return null;
    }
  }

  /// 发送消息到服务器
  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    } else {
      print('Socket 未连接，无法发送消息');
      // 尝试重新连接
      if (_socket != null && !_socket!.connected) {
        print('尝试重新连接 Socket...');
        _socket?.connect();
      }
    }
  }

  /// 监听服务器事件
  void on(String event, Function(dynamic) callback) {
    print('设置监听事件: $event');
    _socket?.on(event, callback);
  }

  /// 取消监听服务器事件
  void off(String event) {
    print('移除监听事件: $event');
    _socket?.off(event);
  }

  /// 检查连接状态并尝试重连
  Future<bool> checkAndReconnect() async {
    if (_socket == null || !_socket!.connected) {
      print('Socket 未连接，尝试重新连接...');
      await connect();
      // 等待短暂时间，看是否连接成功
      await Future.delayed(const Duration(seconds: 2));
      return isConnected.value;
    }
    return true;
  }

  /// 用于调试：打印当前已订阅的所有事件
  void printActiveListeners() {
    if (_socket != null) {
      print('当前Socket.IO事件监听器:');
      print('Socket连接状态: ${_socket!.connected ? "已连接" : "未连接"}');
      print('Socket ID: ${_socket!.id}');
    } else {
      print('Socket未初始化，没有活跃的监听器');
    }
  }

  @override
  void onClose() {
    _heartbeatTimer?.cancel();
    disconnect();
    super.onClose();
  }
}
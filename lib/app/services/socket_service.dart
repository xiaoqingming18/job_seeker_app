import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Socket.IO 服务，管理 WebSocket 连接
class SocketService extends GetxService {
  // localhost 在模拟器/真机上不是指向开发机器，需要使用实际IP地址
  // 对于真机测试，请使用开发机器的实际IP地址
  static const String _serverUrl = 'http://192.168.200.60:9092'; // 使用实际IP地址替代localhost
  static const String _storageTokenKey = 'auth_token';
  
  IO.Socket? _socket;
  final Rx<bool> isConnected = false.obs;

  /// 获取 Socket 实例
  IO.Socket? get socket => _socket;

  /// 初始化 Socket 连接
  Future<SocketService> init() async {
    // 首次初始化时尝试连接
    await connect();
    return this;
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
      
      // 使用令牌作为 URL 参数建立连接
      final socketUrl = '$_serverUrl?token=$token';
      
      print('尝试连接WebSocket: $socketUrl');
      
      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // 使用 WebSocket 传输
            .disableAutoConnect() // 禁用自动连接
            .enableForceNewConnection() // 强制创建新连接
            .setTimeout(10000) // 增加超时时间到10秒
            .setReconnectionAttempts(5) // 设置重连尝试次数
            .setReconnectionDelay(5000) // 重连延迟5秒
            .enableReconnection() // 启用重连
            .build()
      );

      // 设置事件处理
      _setupEventHandlers();
      
      // 手动连接
      _socket?.connect();
      
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
      _socket!.dispose();
      _socket = null;
      isConnected.value = false;
    }
  }

  /// 设置事件处理器
  void _setupEventHandlers() {
    _socket?.onConnect((_) {
      print('Socket.IO 连接成功，ID: ${_socket?.id}');
      isConnected.value = true;
    });

    _socket?.onConnecting((_) {
      print('Socket.IO 正在连接...');
    });

    _socket?.onDisconnect((_) {
      print('Socket.IO 断开连接, 原因: $_');
      isConnected.value = false;
    });

    _socket?.onConnectError((error) {
      print('Socket.IO 连接错误: $error');
      if (kDebugMode) {
        print('连接错误详情: ${error.runtimeType} - $error');
      }
      isConnected.value = false;
    });

    _socket?.onConnectTimeout((_) {
      print('Socket.IO 连接超时');
      isConnected.value = false;
    });

    _socket?.onError((error) {
      print('Socket.IO 错误: $error');
      if (kDebugMode) {
        print('错误详情: ${error.runtimeType} - $error');
      }
    });

    _socket?.onReconnect((_) {
      print('Socket.IO 重新连接成功');
    });

    _socket?.onReconnecting((_) {
      print('Socket.IO 正在尝试重新连接...');
    });

    _socket?.onReconnectError((error) {
      print('Socket.IO 重连错误: $error');
    });

    _socket?.onReconnectFailed((_) {
      print('Socket.IO 重连失败，达到最大尝试次数');
    });
  }

  /// 从本地存储获取令牌
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_storageTokenKey);
      print('获取的令牌: ${token != null ? (token.length > 10 ? "${token.substring(0, 10)}..." : token) : "null"}');
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
    _socket?.on(event, callback);
  }

  /// 取消监听服务器事件
  void off(String event) {
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

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
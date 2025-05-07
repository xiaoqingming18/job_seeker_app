import 'package:get/get.dart';
import 'dart:convert';
import 'socket_service.dart';
import '../models/im_message_model.dart';
import '../models/im_conversation_model.dart';
import 'api/im_api_service.dart';
import 'api/file_api_service.dart';
import 'dart:io';

/// 即时通讯服务
/// 用于处理IM消息并提供即时通讯相关功能
class ImService extends GetxService {
  // Socket 服务
  final SocketService _socketService = Get.find<SocketService>();
  
  // API 服务
  final ImApiService _imApiService = ImApiService();
  
  // 最新消息
  final Rx<ImMessageModel?> latestMessage = Rx<ImMessageModel?>(null);
  
  // 消息列表 - 按会话ID分组
  final RxMap<int, RxList<ImMessageModel>> messagesByConversation = <int, RxList<ImMessageModel>>{}.obs;
  
  // 会话列表
  final RxList<ImConversationModel> conversations = <ImConversationModel>[].obs;
  
  // 未读消息总数
  final RxInt unreadCount = 0.obs;
  
  // 当前用户ID
  final Rx<int?> currentUserId = Rx<int?>(null);
  
  // 新消息通知
  final RxBool hasNewMessage = false.obs;
  final RxInt lastUpdatedConversationId = RxInt(0);
  
  /// 初始化即时通讯服务
  Future<ImService> init() async {
    // 初始设置消息监听
    _setupMessageListeners();
    
    // 监听Socket连接状态变化
    _socketService.isConnected.listen((connected) {
      if (connected) {
        // 当WebSocket连接成功时，重新设置消息监听
        print('WebSocket连接已建立，重新设置IM消息监听...');
        // 先移除现有的监听器，避免重复监听
        _removeMessageListeners();
        // 然后重新设置监听器
        _setupMessageListeners();
      }
    });
    
    return this;
  }
  
  /// 设置当前用户ID
  void setCurrentUserId(int userId) {
    print('ImService: 设置当前用户ID为 $userId');
    currentUserId.value = userId;
  }
  
  /// 设置消息监听
  void _setupMessageListeners() {
    // 监听IM消息事件
    _socketService.on('im:message', _handleMessage);
    
    print('IM消息监听已设置：im:message');
    
    // 主动尝试发送一个订阅消息到WebSocket服务器
    try {
      _socketService.emit('subscribe_events', {
        'events': ['im:message']
      });
      print('已发送IM消息订阅请求');
    } catch (e) {
      print('发送IM消息订阅请求失败: $e');
    }
  }
  
  /// 移除消息监听器，避免重复监听
  void _removeMessageListeners() {
    _socketService.off('im:message');
    print('已移除IM消息监听器');
  }
  
  /// 处理接收到的消息
  void _handleMessage(dynamic data) {
    try {
      print('接收到IM消息: $data');
      
      // 解析消息数据
      Map<String, dynamic> messageData;
      
      if (data is String) {
        // 如果接收到的是字符串，尝试解析 JSON
        messageData = jsonDecode(data);
      } else if (data is Map) {
        // 如果直接是 Map 对象
        messageData = Map<String, dynamic>.from(data);
      } else {
        print('无法识别的IM消息数据格式: ${data.runtimeType}');
        return;
      }
      
      // 如果是发送媒体消息后的响应中包含嵌套的data字段，则提取内部data
      if (messageData.containsKey('data') && messageData['data'] is Map && 
          (messageData['data'] as Map).containsKey('messageType')) {
        print('检测到嵌套数据结构，提取内部data');
        messageData = Map<String, dynamic>.from(messageData['data']);
      }
      
      print('原始消息数据字段: ${messageData.keys}');
      
      // 媒体消息处理：检查和确保关键字段存在
      String messageType = messageData['messageType'] ?? messageData['type'] ?? 'text';
      bool isMediaMessage = messageType == 'image' || messageType == 'video' || messageType == 'audio';
      
      if (isMediaMessage) {
        print('检测到媒体消息，类型: $messageType');
        
        // 检查mediaUrl字段
        if (messageData['mediaUrl'] == null || messageData['mediaUrl'].toString().isEmpty) {
          print('警告: 媒体消息缺少mediaUrl字段');
        } else {
          print('媒体URL: ${messageData['mediaUrl']}');
        }
        
        // 媒体消息需要content字段
        if (messageData['content'] == null || messageData['content'].toString().isEmpty) {
          print('媒体消息content为空，设置默认值');
          messageData['content'] = messageType == 'image' ? '[图片]' : 
                               messageType == 'video' ? '[视频]' : 
                               messageType == 'audio' ? '[语音]' : '[媒体文件]';
        }
      }
      
      // 检查sendTime格式，转换为模型期望的格式
      if (messageData['sendTime'] != null && messageData['sendTime'] is String) {
        try {
          // 如果是ISO格式的字符串，转换为DateTime后提取各个部分
          final DateTime sendTime = DateTime.parse(messageData['sendTime']);
          messageData['sendTime'] = [
            sendTime.year,
            sendTime.month,
            sendTime.day,
            sendTime.hour,
            sendTime.minute,
            sendTime.second,
          ];
          print('转换sendTime格式: ${messageData['sendTime']}');
        } catch (e) {
          print('转换sendTime格式失败: $e');
        }
      }
      
      // 确保会话ID和发送者ID存在
      if (messageData['conversationId'] == null && messageData['senderId'] != null) {
        print('警告: 消息缺少conversationId字段，使用senderId');
        messageData['conversationId'] = messageData['senderId'];
      }
      
      if (messageData['senderId'] == null && currentUserId.value != null) {
        print('警告: 消息缺少senderId字段，使用当前用户ID');
        messageData['senderId'] = currentUserId.value;
      }
      
      // 打印处理后的关键字段
      print('处理后的消息数据:');
      print('- ID: ${messageData['id']}');
      print('- 类型: ${messageData['messageType']}');
      print('- 内容: ${messageData['content']}');
      print('- 媒体URL: ${messageData['mediaUrl']}');
      print('- 发送者: ${messageData['senderId']}');
      print('- 会话ID: ${messageData['conversationId']}');
      
      // 创建消息模型
      final message = ImMessageModel.fromJson(messageData);
      
      // 再次确认关键字段是否正确传递
      print('消息模型创建成功:');
      print('- ID: ${message.id}');
      print('- 类型: ${message.messageType}');
      print('- 内容: ${message.content}');
      print('- 媒体URL: ${message.mediaUrl}');
      print('- 是否媒体消息: ${message.isMediaMessage}');
      
      // 更新最新消息
      latestMessage.value = message;
      
      // 确定会话ID - 优先使用消息中的conversationId
      int conversationId;
      if (message.conversationId != null) {
        conversationId = message.conversationId!;
        print('使用消息中的conversationId: $conversationId');
      } else {
        conversationId = _getConversationId(message);
        print('使用计算得到的conversationId: $conversationId');
      }
      
      // 添加消息到对应会话
      _addMessageToConversation(conversationId, message);
      
      // 更新会话列表中的最后一条消息内容
      _updateConversationLastMessage(conversationId, message);
      
      // 增加未读数量
      _updateUnreadCount();
      
      // 通知UI有新消息
      _notifyNewMessage(conversationId);
      
    } catch (e) {
      print('处理IM消息时出错: $e');
      print('异常详情: ${e.toString()}');
      print('原始数据: $data');
      
      // 尝试创建一个简单的错误消息
      try {
        if (data is Map && data.containsKey('messageType') && 
            (data['messageType'] == 'image' || data['messageType'] == 'video' || data['messageType'] == 'audio')) {
          
          final int senderId = currentUserId.value ?? 0;
          final String messageType = data['messageType'] as String;
          final int? convId = data['conversationId'] is int ? data['conversationId'] : null;
          
          // 创建一个简单的错误消息
          final errorMessage = ImMessageModel(
            id: DateTime.now().millisecondsSinceEpoch,
            conversationId: convId,
            senderId: senderId,
            messageType: messageType,
            content: '[${messageType == 'image' ? '图片' : messageType == 'video' ? '视频' : '语音'}发送失败]',
            status: 'failed',
            mediaUrl: data['mediaUrl'],
          );
          
          final errorConvId = convId ?? senderId;
          
          // 添加到消息列表
          _addMessageToConversation(errorConvId, errorMessage);
          
          // 更新会话
          _updateConversationLastMessage(errorConvId, errorMessage);
          
          // 通知UI
          _notifyNewMessage(errorConvId);
          
          print('已创建错误消息作为备用: $errorMessage');
        }
      } catch (fallbackError) {
        print('创建错误消息也失败了: $fallbackError');
      }
    }
  }
  
  /// 通知UI有新消息
  void _notifyNewMessage(int conversationId) {
    // 设置最后更新的会话ID
    lastUpdatedConversationId.value = conversationId;
    
    // 触发新消息通知
    hasNewMessage.value = !hasNewMessage.value;
    
    print('通知UI更新会话 $conversationId 的最后一条消息');
  }
  
  /// 获取会话ID（当消息中没有指定conversationId时使用）
  int _getConversationId(ImMessageModel message) {
    // 如果有群组标记，使用senderId作为会话ID
    if (message.sender?.role == 'group') {
      return message.senderId;
    }
    
    // 如果是自己发送的消息，对方ID作为会话ID
    if (message.senderId == currentUserId.value && message.conversationId != null) {
      return message.conversationId!;
    }
    
    // 默认使用发送者ID作为会话ID
    return message.senderId;
  }
  
  /// 添加消息到会话
  void _addMessageToConversation(int conversationId, ImMessageModel message) {
    // 如果会话不存在，创建一个新的
    if (!messagesByConversation.containsKey(conversationId)) {
      messagesByConversation[conversationId] = <ImMessageModel>[].obs;
    }
    
    // 检查消息是否已存在（防止重复）
    bool exists = messagesByConversation[conversationId]!.any((m) => m.id == message.id);
    if (!exists) {
      // 添加消息到列表
      messagesByConversation[conversationId]!.add(message);
      
      // 按时间戳排序
      messagesByConversation[conversationId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      print('添加消息到会话 $conversationId: ${message.content}');
    }
  }
  
  /// 更新会话列表中的最后一条消息内容
  void _updateConversationLastMessage(int conversationId, ImMessageModel message) {
    // 查找现有会话
    int existingIndex = conversations.indexWhere((conv) => conv.id == conversationId);
    
    if (existingIndex >= 0) {
      // 更新现有会话
      ImConversationModel updatedConversation = conversations[existingIndex].updateWithMessage(message);
      conversations[existingIndex] = updatedConversation;
      print('更新已有会话 $conversationId 的最后一条消息: ${message.content}');
    } else {
      // 创建新会话
      // 尝试从消息中获取会话名称和头像
      String conversationName;
      String? avatar;
      
      if (message.sender != null) {
        conversationName = message.sender!.username;
        avatar = message.sender!.avatar;
      } else {
        // 如果没有发送者信息，使用默认名称
        conversationName = "会话 $conversationId";
      }
      
      ImConversationModel newConversation = ImConversationModel(
        id: conversationId,
        name: conversationName,
        avatar: avatar,
        lastMessage: message.content,
        lastTimestamp: message.timestamp,
        unreadCount: 1,
        isGroup: message.sender?.role == 'group'
      );
      
      conversations.add(newConversation);
      print('创建新会话 $conversationId: $conversationName, 最后一条消息: ${message.content}');
    }
    
    // 按最后消息时间排序
    conversations.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));
  }
  
  /// 更新未读消息数
  void _updateUnreadCount() {
    int totalUnread = 0;
    for (var conversation in conversations) {
      totalUnread += conversation.unreadCount;
    }
    unreadCount.value = totalUnread;
  }
  
  /// 发送消息
  Future<void> sendMessage(
    int receiverId, 
    String content, {
    String messageType = 'text',
    bool isGroup = false,
    int? conversationId
  }) async {
    if (currentUserId.value == null) {
      print('错误：未设置当前用户ID，无法发送消息');
      return;
    }
    
    // 使用传入的conversationId或者接收者ID
    int actualConversationId = conversationId ?? receiverId;
    
    try {
      // 使用新的API发送文本消息
      final responseData = await _imApiService.sendTextMessage(
        conversationId: actualConversationId,
        senderId: currentUserId.value!,
        content: content
      );
      
      print('消息发送成功: $responseData');
      
      // 处理响应数据，创建消息对象
      if (responseData != null) {
        final message = ImMessageModel.fromJson(responseData);
        
        // 本地处理这条消息（即发送后立即显示）
        _handleMessage(responseData);
      }
    } catch (e) {
      print('发送消息失败: $e');
      
      // 发送失败时，仍然显示一个本地消息，但标记为发送失败状态
      final tempMessage = {
        'id': DateTime.now().millisecondsSinceEpoch, // 临时ID
        'conversationId': actualConversationId,
        'senderId': currentUserId.value,
        'messageType': messageType,
        'content': content,
        'sendTime': [
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second,
        ],
        'status': 'failed', // 标记为发送失败
        'isRecalled': false,
      };
      
      // 在本地处理这条失败的消息
      _handleMessage(tempMessage);
    }
  }
  
  /// 标记会话为已读
  /// 注意：该功能已禁用，方法保留仅为兼容性考虑
  void markConversationAsRead(int conversationId) {
    // 此功能已禁用
    print('标记已读功能已禁用: 会话ID=$conversationId');
    
    // 不再执行任何标记已读的操作
  }
  
  /// 获取会话消息列表
  List<ImMessageModel> getConversationMessages(int conversationId) {
    if (messagesByConversation.containsKey(conversationId)) {
      return messagesByConversation[conversationId]!;
    }
    return [];
  }
  
  /// 发送测试消息（用于测试）
  void sendTestMessage() {
    final testMessageData = {
      'id': 1000,
      'conversationId': 999,
      'senderId': 888,
      'messageType': 'text',
      'content': '这是一条测试消息',
      'sendTime': [
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      ],
      'status': 'sent',
      'sender': {
        'id': 888,
        'username': '测试用户',
        'avatar': null,
        'role': 'user'
      }
    };
    
    _handleMessage(testMessageData);
  }

  /// 发送媒体消息（图片、视频、音频）
  Future<void> sendMediaMessage(
    int receiverId,
    File mediaFile,
    String messageType, {
    bool isGroup = false,
    int? conversationId,
    Function(double progress)? onProgress
  }) async {
    if (currentUserId.value == null) {
      print('错误：未设置当前用户ID，无法发送消息');
      return;
    }
    
    // 使用传入的conversationId或者接收者ID
    int actualConversationId = conversationId ?? receiverId;
    
    try {
      // 1. 首先上传媒体文件
      final FileApiService fileApiService = FileApiService();
      String mediaUrl;
      
      // 根据不同的媒体类型选择不同的上传方法
      switch (messageType) {
        case 'image':
          mediaUrl = await fileApiService.uploadImage(
            mediaFile,
            onProgress: (sent, total) {
              if (onProgress != null) {
                onProgress(sent / total);
              }
            }
          );
          break;
        case 'video':
          mediaUrl = await fileApiService.uploadVideo(
            mediaFile,
            onProgress: (sent, total) {
              if (onProgress != null) {
                onProgress(sent / total);
              }
            }
          );
          break;
        case 'audio':
          mediaUrl = await fileApiService.uploadAudio(
            mediaFile,
            onProgress: (sent, total) {
              if (onProgress != null) {
                onProgress(sent / total);
              }
            }
          );
          break;
        default:
          throw Exception('不支持的媒体类型: $messageType');
      }
      
      print('媒体文件上传成功，URL: $mediaUrl，准备发送媒体消息，会话ID: $actualConversationId');
      
      // 2. 上传成功后，发送媒体消息
      final responseData = await _imApiService.sendMediaMessage(
        conversationId: actualConversationId,
        senderId: currentUserId.value!,
        messageType: messageType,
        mediaUrl: mediaUrl
      );
      
      print('媒体消息发送成功，API响应数据: $responseData');
      
      // 检查响应数据中的mediaUrl是否正确
      if (responseData['mediaUrl'] == null) {
        print('警告：媒体消息响应中缺少mediaUrl字段，添加本地URL');
        responseData['mediaUrl'] = mediaUrl;
      }
      
      // 如果content为空，设置一个默认值
      if (responseData['content'] == null) {
        print('警告：媒体消息响应中content为空，设置默认文本描述');
        responseData['content'] = messageType == 'image' ? '[图片]' : 
                                  messageType == 'video' ? '[视频]' : 
                                  messageType == 'audio' ? '[语音]' : '[媒体文件]';
      }
      
      // 确保messageType字段存在
      if (responseData['messageType'] == null) {
        print('警告：媒体消息响应中messageType字段缺失，使用本地类型');
        responseData['messageType'] = messageType;
      }

      // 确保senderId字段存在
      if (responseData['senderId'] == null) {
        print('警告：媒体消息响应中senderId字段缺失，使用当前用户ID');
        responseData['senderId'] = currentUserId.value;
      }

      // 确保conversationId字段存在
      if (responseData['conversationId'] == null) {
        print('警告：媒体消息响应中conversationId字段缺失，使用实际会话ID');
        responseData['conversationId'] = actualConversationId;
      }
      
      print('处理后的响应数据字段: ${responseData.keys}');
      print('mediaUrl: ${responseData['mediaUrl']}');
      print('messageType: ${responseData['messageType']}');
      print('content: ${responseData['content']}');
      
      // 先构建一个测试消息确认数据格式正确
      try {
        final testMessage = ImMessageModel.fromJson(responseData);
        print('测试消息构建成功: 类型=${testMessage.messageType}, URL=${testMessage.mediaUrl}');
      } catch (e) {
        print('测试消息构建失败: $e');
      }
      
      // 本地处理这条消息（即发送后立即显示）
      _handleMessage(responseData);
      
      print('媒体消息已添加到消息列表中');
    } catch (e) {
      print('发送媒体消息失败: $e');
      
      // 发送失败时，仍然显示一个本地消息，但标记为发送失败状态
      final tempMessage = {
        'id': DateTime.now().millisecondsSinceEpoch, // 临时ID
        'conversationId': actualConversationId,
        'senderId': currentUserId.value,
        'messageType': messageType,
        'content': messageType == 'image' ? '[图片]' : 
                   messageType == 'video' ? '[视频]' : 
                   messageType == 'audio' ? '[语音]' : '[媒体文件]',
        'mediaUrl': mediaFile.path, // 本地路径作为媒体URL（仅用于本地显示）
        'sendTime': [
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second,
        ],
        'status': 'failed', // 标记为发送失败
        'isRecalled': false,
      };
      
      print('创建失败消息: $tempMessage');
      
      // 在本地处理这条失败的消息
      _handleMessage(tempMessage);
    }
  }

  @override
  void onClose() {
    // 取消IM消息的监听
    _removeMessageListeners();
    super.onClose();
  }
} 
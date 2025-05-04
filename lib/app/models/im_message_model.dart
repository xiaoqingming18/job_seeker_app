/// IM消息类型枚举
enum ImMessageType {
  text,    // 文本消息
  image,   // 图片消息
  voice,   // 语音消息
  video,   // 视频消息
  file,    // 文件消息
  system,  // 系统消息
}

/// 消息状态枚举
enum MessageStatus {
  sending,   // 发送中
  sent,      // 已发送
  delivered, // 已送达
  read,      // 已读
  failed     // 发送失败
}

/// 用户简要信息
class UserInfo {
  final int id;               // 用户ID
  final String username;      // 用户名
  final String? avatar;       // 头像
  final String? role;         // 角色
  final String? email;        // 邮箱
  final String? mobile;       // 手机号

  UserInfo({
    required this.id,
    required this.username,
    this.avatar,
    this.role,
    this.email,
    this.mobile,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      avatar: json['avatar'],
      role: json['role'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (avatar != null) 'avatar': avatar,
      if (role != null) 'role': role,
      if (email != null) 'email': email,
      if (mobile != null) 'mobile': mobile,
    };
  }
}

/// IM消息模型
class ImMessageModel {
  final int id;                     // 消息ID
  final int? conversationId;        // 会话ID
  final int senderId;               // 发送者ID
  final String messageType;         // 消息类型
  final String content;             // 消息内容
  final String? mediaUrl;           // 媒体URL
  final String? fileName;           // 文件名
  final int? fileSize;              // 文件大小
  final int? replyToId;             // 回复消息ID
  final bool isRecalled;            // 是否撤回
  final List<dynamic>? sendTime;    // 发送时间 [年,月,日,时,分,秒,纳秒]
  final String status;              // 消息状态
  final UserInfo? sender;           // 发送者信息
  final ImMessageModel? replyMessage; // 回复的消息
  final List<dynamic>? readStatusList;// 已读状态列表
  
  // 计算得到的属性
  int? _timestamp;                  // 时间戳(毫秒)

  ImMessageModel({
    required this.id,
    this.conversationId,
    required this.senderId,
    required this.messageType,
    required this.content,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.replyToId,
    this.isRecalled = false,
    this.sendTime,
    required this.status,
    this.sender,
    this.replyMessage,
    this.readStatusList,
  }) {
    // 将sendTime转换为时间戳
    if (sendTime != null && sendTime!.length >= 6) {
      try {
        final year = sendTime![0] as int;
        final month = sendTime![1] as int;
        final day = sendTime![2] as int;
        final hour = sendTime![3] as int;
        final minute = sendTime![4] as int;
        final second = sendTime![5] as int;
        
        final dateTime = DateTime(year, month, day, hour, minute, second);
        _timestamp = dateTime.millisecondsSinceEpoch;
      } catch (e) {
        print('解析时间出错: $e');
        _timestamp = DateTime.now().millisecondsSinceEpoch;
      }
    } else {
      _timestamp = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// 从JSON构造
  factory ImMessageModel.fromJson(Map<String, dynamic> json) {
    print('解析消息JSON: ${json.keys}');
    
    // 解析senderId，支持String和int类型
    int parsedSenderId;
    if (json['senderId'] is String) {
      parsedSenderId = int.tryParse(json['senderId']) ?? 0;
    } else {
      parsedSenderId = json['senderId'] ?? 0;
    }
    
    // 解析conversationId，支持String和int类型
    int? parsedConversationId;
    if (json['conversationId'] != null) {
      if (json['conversationId'] is String) {
        parsedConversationId = int.tryParse(json['conversationId']);
      } else {
        parsedConversationId = json['conversationId'];
      }
    }
    
    // 解析消息ID，支持String和int类型
    int parsedId;
    if (json['id'] is String) {
      parsedId = int.tryParse(json['id']) ?? 0;
    } else {
      parsedId = json['id'] ?? 0;
    }
    
    // 获取消息类型
    String messageType = json['messageType'] ?? json['type'] ?? 'text';
    
    // 如果是媒体消息但content为空，设置默认内容
    String content = json['content'] ?? '';
    if (content.isEmpty && (messageType == 'image' || messageType == 'video' || messageType == 'audio')) {
      content = messageType == 'image' ? '[图片]' : 
               messageType == 'video' ? '[视频]' : 
               messageType == 'audio' ? '[语音]' : '[媒体文件]';
    }
    
    print('解析消息 ID=$parsedId, 类型=$messageType, mediaUrl=${json['mediaUrl']}');
    
    return ImMessageModel(
      id: parsedId,
      conversationId: parsedConversationId,
      senderId: parsedSenderId,
      messageType: messageType,
      content: content,
      mediaUrl: json['mediaUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      replyToId: json['replyToId'],
      isRecalled: json['isRecalled'] ?? false,
      sendTime: json['sendTime'],
      status: json['status'] ?? 'sent',
      sender: json['sender'] != null ? UserInfo.fromJson(json['sender']) : null,
      replyMessage: json['replyMessage'] != null 
          ? ImMessageModel.fromJson(json['replyMessage']) 
          : null,
      readStatusList: json['readStatusList'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (conversationId != null) 'conversationId': conversationId,
      'senderId': senderId,
      'messageType': messageType,
      'content': content,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (replyToId != null) 'replyToId': replyToId,
      'isRecalled': isRecalled,
      if (sendTime != null) 'sendTime': sendTime,
      'status': status,
      if (sender != null) 'sender': sender!.toJson(),
      if (replyMessage != null) 'replyMessage': replyMessage!.toJson(),
      if (readStatusList != null) 'readStatusList': readStatusList,
    };
  }

  /// 获取时间戳(毫秒)
  int get timestamp => _timestamp ?? DateTime.now().millisecondsSinceEpoch;
  
  /// 判断是否为媒体消息
  bool get isMediaMessage => 
      messageType == 'image' || 
      messageType == 'voice' || 
      messageType == 'video' || 
      messageType == 'file';
  
  /// 判断消息是否已读
  bool get isRead => status == 'read';
  
  /// 获取接收者ID (仅当conversationId存在时有效)
  int? get receiverId => conversationId;

  /// 创建已读副本
  ImMessageModel copyWithRead() {
    return ImMessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      messageType: messageType,
      content: content,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      replyToId: replyToId,
      isRecalled: isRecalled,
      sendTime: sendTime,
      status: 'read',
      sender: sender,
      replyMessage: replyMessage,
      readStatusList: readStatusList,
    );
  }

  /// 获取格式化的时间
  String get formattedTime {
    final messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (messageTime.year == now.year && 
        messageTime.month == now.month && 
        messageTime.day == now.day) {
      // 今天的消息，只显示时间
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    } else if (messageTime.year == now.year) {
      // 今年的消息，显示月日时间
      return '${messageTime.month}月${messageTime.day}日 ${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 其他年份的消息，显示完整日期
      return '${messageTime.year}年${messageTime.month}月${messageTime.day}日 ${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
  }
  
  /// 获取发送者名称
  String get senderName => sender?.username ?? '用户$senderId';
} 
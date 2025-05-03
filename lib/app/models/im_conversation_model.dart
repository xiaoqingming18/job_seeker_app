import 'im_message_model.dart';

/// IM会话模型
class ImConversationModel {
  final int id;                // 会话ID
  final String name;           // 会话名称
  final String? avatar;        // 会话头像
  final String lastMessage;    // 最后一条消息内容
  final int lastTimestamp;     // 最后更新时间
  final int unreadCount;       // 未读消息数
  final bool isGroup;          // 是否为群聊
  final List<int>? participants;  // 参与者ID列表

  ImConversationModel({
    required this.id,
    required this.name,
    this.avatar,
    this.lastMessage = '',
    required this.lastTimestamp,
    this.unreadCount = 0,
    this.isGroup = false,
    this.participants,
  });

  /// 从JSON构造
  factory ImConversationModel.fromJson(Map<String, dynamic> json) {
    // 处理id可能是字符串的情况
    int conversationId;
    if (json['id'] is String) {
      conversationId = int.tryParse(json['id']) ?? 0;
    } else {
      conversationId = json['id'] ?? 0;
    }
    
    // 处理参与者列表
    List<int>? userIds;
    if (json['participants'] != null) {
      userIds = (json['participants'] as List).map((item) {
        if (item is int) return item;
        if (item is String) return int.tryParse(item) ?? 0;
        if (item is Map && item.containsKey('id')) {
          var id = item['id'];
          if (id is int) return id;
          if (id is String) return int.tryParse(id) ?? 0;
        }
        return 0;
      }).toList();
    }

    return ImConversationModel(
      id: conversationId,
      name: json['name'] ?? '',
      avatar: json['avatar'],
      lastMessage: json['lastMessage'] ?? '',
      lastTimestamp: json['lastTimestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      unreadCount: json['unreadCount'] ?? 0,
      isGroup: json['isGroup'] ?? false,
      participants: userIds,
    );
  }

  /// 从消息构造会话
  factory ImConversationModel.fromMessage(ImMessageModel message, {
    required String name,
    String? avatar,
    bool isGroup = false,
    List<int>? participants,
  }) {
    // 如果消息中包含会话ID，则使用它
    int conversationId = message.conversationId ?? message.id;
    
    return ImConversationModel(
      id: conversationId,
      name: name,
      avatar: avatar,
      lastMessage: message.content,
      lastTimestamp: message.timestamp,
      unreadCount: 1,
      isGroup: isGroup,
      participants: participants,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (avatar != null) 'avatar': avatar,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      if (participants != null) 'participants': participants,
    };
  }

  /// 更新会话（添加新消息）
  ImConversationModel updateWithMessage(ImMessageModel message, {bool isRead = false}) {
    return ImConversationModel(
      id: id,
      name: name,
      avatar: avatar,
      lastMessage: message.content,
      lastTimestamp: message.timestamp,
      unreadCount: isRead ? unreadCount : unreadCount + 1,
      isGroup: isGroup,
      participants: participants,
    );
  }

  /// 标记为已读
  ImConversationModel markAsRead() {
    return ImConversationModel(
      id: id,
      name: name,
      avatar: avatar,
      lastMessage: lastMessage,
      lastTimestamp: lastTimestamp,
      unreadCount: 0,
      isGroup: isGroup,
      participants: participants,
    );
  }

  /// 获取格式化的最后消息时间
  String get formattedTime {
    final messageTime = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
    final now = DateTime.now();
    
    if (messageTime.year == now.year && 
        messageTime.month == now.month && 
        messageTime.day == now.day) {
      // 今天的消息，只显示时间
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(messageTime).inDays <= 7) {
      // 一周内的消息，显示星期
      List<String> weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return weekdays[messageTime.weekday % 7];
    } else if (messageTime.year == now.year) {
      // 今年的消息，显示月日
      return '${messageTime.month}月${messageTime.day}日';
    } else {
      // 其他年份的消息，显示年月日
      return '${messageTime.year}/${messageTime.month}/${messageTime.day}';
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api/im_api_service.dart';
import '../../../services/api/user_api_service.dart';
import '../../../models/user_model.dart';
import '../../../services/im_service.dart';
import '../../../models/im_conversation_model.dart';
import '../../../routes/app_pages.dart';

/// IM会话控制器
/// 负责管理IM会话列表和消息
class ImController extends GetxController {
  // API 服务
  final ImApiService _imApiService = ImApiService();
  final UserApiService _userApiService = UserApiService();
  
  // WebSocket 服务
  final ImService _imService = Get.find<ImService>();
  
  // 用户ID，需要在初始化时设置
  final Rx<int?> userId = Rx<int?>(null);
  
  // 会话列表
  final RxList<Map<String, dynamic>> conversations = <Map<String, dynamic>>[].obs;
  
  // 会话成员映射表 - 键为会话ID，值为成员列表
  final RxMap<int, List<Map<String, dynamic>>> conversationMembers = <int, List<Map<String, dynamic>>>{}.obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  
  // 错误信息
  final RxString errorMessage = ''.obs;
  
  // 新消息监听器
  late Worker _newMessageWorker;
  
  @override
  void onInit() {
    super.onInit();
    // 获取当前用户ID
    _getCurrentUserId();
    
    // 监听新消息通知
    _setupNewMessageListener();
  }
  
  @override
  void onClose() {
    // 取消新消息监听器
    _newMessageWorker.dispose();
    super.onClose();
  }
  
  /// 设置新消息监听器
  void _setupNewMessageListener() {
    // 当ImService中的hasNewMessage变化时触发
    _newMessageWorker = ever(_imService.hasNewMessage, (_) {
      // 获取最后更新的会话ID
      int conversationId = _imService.lastUpdatedConversationId.value;
      if (conversationId > 0) {
        print('ImController: 收到会话 $conversationId 的新消息通知');
        _updateConversationInList(conversationId);
      }
    });
  }
  
  /// 更新会话列表中的指定会话
  void _updateConversationInList(int conversationId) {
    // 查找ImService中的会话数据
    int serviceIndex = _imService.conversations.indexWhere((conv) => conv.id == conversationId);
    if (serviceIndex >= 0) {
      // 获取ImService中的会话数据
      final serviceConversation = _imService.conversations[serviceIndex];
      
      // 查找本地会话列表中的对应会话
      int localIndex = conversations.indexWhere((conv) => conv['id'] == conversationId);
      
      if (localIndex >= 0) {
        // 如果本地列表中存在，更新它
        final updatedConversation = Map<String, dynamic>.from(conversations[localIndex]);
        updatedConversation['content'] = serviceConversation.lastMessage;
        updatedConversation['time'] = _formatMessageTime(DateTime.fromMillisecondsSinceEpoch(serviceConversation.lastTimestamp));
        
        // 更新本地列表
        conversations[localIndex] = updatedConversation;
        print('更新本地会话列表中会话 $conversationId 的最后一条消息: ${serviceConversation.lastMessage}');
        
        // 按时间排序
        _sortConversationsByTime();
      } else {
        // 如果本地列表中不存在，创建新的会话项
        final newConversation = {
          'id': serviceConversation.id,
          'type': 'im_conversation',
          'title': serviceConversation.name,
          'content': serviceConversation.lastMessage,
          'time': _formatMessageTime(DateTime.fromMillisecondsSinceEpoch(serviceConversation.lastTimestamp)),
          'isRead': serviceConversation.unreadCount == 0,
          'avatar': Icons.chat.toString(),
          'avatarBgColor': 'teal.100',
          'avatarColor': 'teal',
          'rawData': {
            'id': serviceConversation.id,
            'title': serviceConversation.name,
            'avatar': serviceConversation.avatar,
            'lastMessage': serviceConversation.lastMessage,
            'lastTimestamp': serviceConversation.lastTimestamp,
          },
        };
        
        conversations.add(newConversation);
        print('添加新会话到本地列表: ${serviceConversation.name}, 消息: ${serviceConversation.lastMessage}');
        
        // 按时间排序
        _sortConversationsByTime();
        
        // 获取会话成员
        _fetchConversationMembers(serviceConversation.id);
      }
    }
  }
  
  /// 按最后消息时间排序会话列表
  void _sortConversationsByTime() {
    // 只对IM会话类型进行排序
    final List<Map<String, dynamic>> imConversations = conversations
        .where((conv) => conv['type'] == 'im_conversation')
        .toList();
    
    final List<Map<String, dynamic>> otherItems = conversations
        .where((conv) => conv['type'] != 'im_conversation')
        .toList();
    
    // 对IM会话按时间戳排序（降序）
    imConversations.sort((a, b) {
      final aTimestamp = a['rawData']['lastTimestamp'] as int? ?? 0;
      final bTimestamp = b['rawData']['lastTimestamp'] as int? ?? 0;
      return bTimestamp.compareTo(aTimestamp);
    });
    
    // 重新组合列表
    conversations.value = [...imConversations, ...otherItems];
  }
  
  /// 设置当前用户ID
  void setCurrentUserId(int id) {
    userId.value = id;
    _imService.setCurrentUserId(id);
    loadConversations();
  }
  
  /// 获取当前用户ID
  Future<void> _getCurrentUserId() async {
    try {
      // 优先从缓存获取用户资料
      final userProfile = await _userApiService.getCachedJobseekerProfile();
      
      if (userProfile != null && userProfile.userId != null) {
        userId.value = userProfile.userId;
        print('从缓存获取到用户ID: ${userId.value}');
        _imService.setCurrentUserId(userId.value!);
        loadConversations();
        return;
      }
      
      // 如果缓存中没有，尝试验证token获取用户信息
      final tokenResponse = await _userApiService.verifyToken();
      if (tokenResponse.isSuccess && tokenResponse.data != null) {
        userId.value = tokenResponse.data!.userId;
        print('从token验证获取到用户ID: ${userId.value}');
        _imService.setCurrentUserId(userId.value!);
        loadConversations();
        return;
      }
      
      // 如果还是没有获取到，尝试从服务器获取用户资料
      final response = await _userApiService.fetchAndCacheJobseekerProfile();
      if (response.isSuccess && response.data != null && response.data!.userId != null) {
        userId.value = response.data!.userId;
        print('从服务器获取到用户ID: ${userId.value}');
        _imService.setCurrentUserId(userId.value!);
        loadConversations();
        return;
      }
      
      // 如果所有方法都无法获取到用户ID，显示错误
      errorMessage.value = '无法获取用户ID，请确保已登录';
      print('无法获取用户ID');
    } catch (e) {
      errorMessage.value = '获取用户ID失败: $e';
      print('获取用户ID失败: $e');
    }
  }
  
  /// 加载会话列表
  Future<void> loadConversations() async {
    if (userId.value == null) {
      errorMessage.value = '未设置用户ID，无法加载会话列表';
      print('未设置用户ID，无法加载会话列表');
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      print('正在加载用户ID ${userId.value} 的会话列表...');
      final List<Map<String, dynamic>> userConversations = 
          await _imApiService.getUserConversations(userId.value!);
      
      // 转换会话列表格式，以适应UI展示需求
      conversations.value = userConversations.map((conversation) {
        // 提取最后一条消息
        final lastMessage = conversation['lastMessage'] ?? {};
        
        // 计算时间
        String time = '未知';
        int lastTimestamp = DateTime.now().millisecondsSinceEpoch; // 默认时间戳
        
        if (lastMessage['sendTime'] != null) {
          try {
            final DateTime sendTime = DateTime.parse(lastMessage['sendTime']);
            time = _formatMessageTime(sendTime);
            lastTimestamp = sendTime.millisecondsSinceEpoch;
          } catch (e) {
            print('解析时间错误: $e');
          }
        } else if (conversation['createTime'] != null) {
          try {
            final DateTime createTime = DateTime.parse(conversation['createTime']);
            time = _formatMessageTime(createTime);
            lastTimestamp = createTime.millisecondsSinceEpoch;
          } catch (e) {
            print('解析时间错误: $e');
          }
        }
        
        // 为便于排序，将lastTimestamp保存到rawData中
        final Map<String, dynamic> rawData = Map<String, dynamic>.from(conversation);
        rawData['lastTimestamp'] = lastTimestamp;
        
        return {
          'id': conversation['id'],
          'type': 'im_conversation',
          'title': conversation['title'] ?? '未命名会话',
          'content': lastMessage['content'] ?? '暂无消息',
          'time': time,
          'isRead': true, // 默认为已读，后续可根据实际情况修改
          'avatar': Icons.chat.toString(), // 使用字符串表示图标
          'avatarBgColor': 'teal.100', // 使用字符串表示颜色
          'avatarColor': 'teal', // 使用字符串表示颜色
          'rawData': rawData, // 保存原始数据
        };
      }).toList();
      
      // 更新ImService中的会话状态
      _updateImServiceConversations(userConversations);
      
      // 开始获取每个会话的成员信息
      for (final conversation in userConversations) {
        _fetchConversationMembers(conversation['id']);
      }
      
      print('加载会话列表成功，共 ${conversations.length} 个会话');
      isLoading.value = false;
    } catch (e) {
      print('加载会话列表错误: $e');
      errorMessage.value = '加载会话列表失败: $e';
      isLoading.value = false;
    }
  }
  
  /// 获取会话成员信息
  Future<void> _fetchConversationMembers(int conversationId) async {
    try {
      print('获取会话 $conversationId 的成员信息...');
      final List<Map<String, dynamic>> members = 
          await _imApiService.getConversationMembers(conversationId);
      
      // 将会话成员保存到映射表中
      conversationMembers[conversationId] = members;
      
      // 输出调试信息
      print('会话 $conversationId 的成员信息:');
      for (final member in members) {
        print('  - 成员ID: ${member['userId']}, 昵称: ${member['nickname']}, 角色: ${member['role']}');
      }
      
      // 组合会话和成员数据，输出到控制台
      _printCombinedConversationData(conversationId);
      
    } catch (e) {
      print('获取会话 $conversationId 的成员信息失败: $e');
    }
  }
  
  /// 打印组合后的会话数据
  void _printCombinedConversationData(int conversationId) {
    // 找到会话数据
    final conversation = conversations.firstWhere(
      (conv) => conv['id'] == conversationId,
      orElse: () => <String, dynamic>{},
    );
    
    // 如果找不到会话数据，直接返回
    if (conversation.isEmpty) {
      print('找不到会话 $conversationId 的数据');
      return;
    }
    
    // 获取会话成员数据
    final members = conversationMembers[conversationId] ?? [];
    
    // 组合数据结构
    final combinedData = {
      'conversation': conversation,
      'members': members,
      'currentUserId': userId.value,
    };
    
    // 输出组合后的数据结构
    print('========== 会话 $conversationId 的完整数据 ==========');
    print('会话标题: ${conversation['title']}');
    print('最后消息: ${conversation['content']}');
    print('时间: ${conversation['time']}');
    print('成员数量: ${members.length}');
    print('成员列表:');
    for (final member in members) {
      print('  - ID: ${member['userId']}, 昵称: ${member['nickname']}, 角色: ${member['role']}, 加入时间: ${member['joinTime']}');
    }
    print('当前用户ID: ${userId.value}');
    print('===============================================');
  }
  
  /// 更新ImService中的会话状态
  void _updateImServiceConversations(List<Map<String, dynamic>> apiConversations) {
    for (final conversation in apiConversations) {
      final int conversationId = conversation['id'];
      final lastMessage = conversation['lastMessage'] ?? {};
      
      // 检查ImService中是否已存在该会话
      int index = _imService.conversations.indexWhere((conv) => conv.id == conversationId);
      
      if (index < 0) {
        // 如果ImService中不存在，创建新会话
        ImConversationModel newConversation = ImConversationModel(
          id: conversationId,
          name: conversation['title'] ?? '未命名会话',
          avatar: conversation['avatar'],
          lastMessage: lastMessage['content'] ?? '暂无消息',
          lastTimestamp: DateTime.now().millisecondsSinceEpoch, // 临时时间戳
          unreadCount: 0,
          isGroup: conversation['conversationType'] == 'group',
        );
        
        // 添加到ImService
        _imService.conversations.add(newConversation);
      }
    }
  }
  
  /// 格式化消息时间
  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (dateTime.year == now.year) {
      return '${dateTime.month}-${dateTime.day}';
    } else {
      return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
    }
  }
  
  /// 获取会话成员数据
  List<Map<String, dynamic>>? getConversationMembers(int conversationId) {
    return conversationMembers[conversationId];
  }
  
  /// 打开会话详情
  void openConversation(int conversationId) {
    // 获取会话目标用户ID（对于单聊）或会话ID（对于群聊）
    int targetUserId = 0;
    bool isGroup = false;
    
    // 查找会话在ImService中的数据
    int serviceIndex = _imService.conversations.indexWhere((conv) => conv.id == conversationId);
    if (serviceIndex >= 0) {
      isGroup = _imService.conversations[serviceIndex].isGroup;
    }
    
    // 如果不是群聊，查找会话的目标用户ID
    if (!isGroup) {
      // 从会话成员中查找非当前用户的成员ID
      final members = conversationMembers[conversationId] ?? [];
      for (final member in members) {
        int memberId = member['userId'];
        if (memberId != userId.value) {
          targetUserId = memberId;
          break;
        }
      }
      
      // 如果会话成员中没有找到，使用会话ID作为目标用户ID
      if (targetUserId == 0) {
        // 对于一对一聊天，通常会话ID就是对方的用户ID
        targetUserId = conversationId;
      }
    }
    
    // 打印会话信息
    print('打开会话: ID=$conversationId, 是否群聊=$isGroup, 目标用户ID=$targetUserId');
    
    // 导航到聊天详情页面，传递会话ID和目标用户ID
    Get.toNamed(
      Routes.CHAT_DETAIL,
      parameters: {
        'id': conversationId.toString(),
        'targetUserId': targetUserId.toString(),
        'isGroup': isGroup.toString(),
      },
    );
  }
} 
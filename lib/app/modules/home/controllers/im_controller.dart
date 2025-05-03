import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api/im_api_service.dart';
import '../../../services/api/user_api_service.dart';
import '../../../models/user_model.dart';
import '../../../services/im_service.dart';

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
  
  // 加载状态
  final RxBool isLoading = false.obs;
  
  // 错误信息
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // 获取当前用户ID
    _getCurrentUserId();
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
        if (lastMessage['sendTime'] != null) {
          try {
            final DateTime sendTime = DateTime.parse(lastMessage['sendTime']);
            time = _formatMessageTime(sendTime);
          } catch (e) {
            print('解析时间错误: $e');
          }
        } else if (conversation['createTime'] != null) {
          try {
            final DateTime createTime = DateTime.parse(conversation['createTime']);
            time = _formatMessageTime(createTime);
          } catch (e) {
            print('解析时间错误: $e');
          }
        }
        
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
          'rawData': conversation, // 保存原始数据
        };
      }).toList();
      
      print('加载会话列表成功，共 ${conversations.length} 个会话');
      isLoading.value = false;
    } catch (e) {
      print('加载会话列表错误: $e');
      errorMessage.value = '加载会话列表失败: $e';
      isLoading.value = false;
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
  
  /// 打开会话详情
  void openConversation(int conversationId) {
    // TODO: 导航到会话详情页面
    Get.snackbar('提示', '正在开发会话详情功能...');
  }
} 
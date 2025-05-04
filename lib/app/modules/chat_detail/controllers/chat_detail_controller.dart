import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/im_message_model.dart';
import '../../../models/im_conversation_model.dart';
import '../../../services/im_service.dart';

/// 聊天详情控制器
class ChatDetailController extends GetxController {
  // IM服务
  final ImService _imService = Get.find<ImService>();
  
  // 会话ID
  final int conversationId;
  
  // 消息控制器
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  // 会话信息
  final Rx<ImConversationModel?> conversation = Rx<ImConversationModel?>(null);
  
  // 消息列表
  final RxList<ImMessageModel> messages = <ImMessageModel>[].obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  
  // 是否显示发送按钮（输入框有内容时显示）
  final RxBool showSendButton = false.obs;
  
  // 当前用户ID
  int? get currentUserId => _imService.currentUserId.value;
  
  // 构造函数，需要传入会话ID
  ChatDetailController({required this.conversationId});
  
  @override
  void onInit() {
    super.onInit();
    // 加载会话信息
    _loadConversation();
    
    // 加载消息列表
    _loadMessages();
    
    // 监听消息输入变化
    messageController.addListener(_onMessageInputChanged);
    
    // 监听新消息通知
    _setupNewMessageListener();
    
    // 标记消息为已读
    _markAsRead();
  }
  
  @override
  void onClose() {
    // 释放控制器
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  
  /// 监听输入框变化
  void _onMessageInputChanged() {
    showSendButton.value = messageController.text.trim().isNotEmpty;
  }
  
  /// 设置新消息监听
  void _setupNewMessageListener() {
    // 当ImService的hasNewMessage状态变化时
    ever(_imService.hasNewMessage, (_) {
      // 检查是否是当前会话的新消息
      if (_imService.lastUpdatedConversationId.value == conversationId) {
        // 重新加载消息
        _loadMessages();
        
        // 滚动到底部
        _scrollToBottom();
        
        // 标记为已读
        _markAsRead();
      }
    });
  }
  
  /// 加载会话信息
  void _loadConversation() {
    int index = _imService.conversations.indexWhere((conv) => conv.id == conversationId);
    if (index >= 0) {
      conversation.value = _imService.conversations[index];
    } else {
      print('找不到会话 $conversationId');
      Get.back(); // 如果找不到会话，返回上一页
    }
  }
  
  /// 加载消息列表
  void _loadMessages() {
    isLoading.value = true;
    
    try {
      // 从ImService中获取消息
      if (_imService.messagesByConversation.containsKey(conversationId)) {
        messages.value = _imService.messagesByConversation[conversationId]!;
      } else {
        messages.value = [];
      }
      
      print('加载会话 $conversationId 的消息，共 ${messages.length} 条');
      isLoading.value = false;
      
      // 加载完成后滚动到底部
      if (messages.isNotEmpty) {
        _scrollToBottom();
      }
    } catch (e) {
      print('加载消息失败: $e');
      isLoading.value = false;
    }
  }
  
  /// 标记消息为已读
  void _markAsRead() {
    if (conversationId > 0) {
      _imService.markConversationAsRead(conversationId);
    }
  }
  
  /// 发送消息
  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;
    
    if (currentUserId == null) {
      Get.snackbar('错误', '未获取到用户ID，无法发送消息');
      return;
    }
    
    isSending.value = true;
    
    try {
      // 发送消息
      _imService.sendMessage(
        conversation.value?.id ?? conversationId, 
        messageText, 
        messageType: 'text',
        isGroup: conversation.value?.isGroup ?? false,
        conversationId: conversationId
      );
      
      // 清空输入框
      messageController.clear();
      
      // 重置发送按钮状态
      showSendButton.value = false;
      
      // 滚动到底部
      _scrollToBottom();
      
      isSending.value = false;
    } catch (e) {
      print('发送消息失败: $e');
      isSending.value = false;
      Get.snackbar('发送失败', '消息发送失败，请稍后再试');
    }
  }
  
  /// 滚动到底部
  void _scrollToBottom() {
    // 使用延迟确保布局完成
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients && messages.isNotEmpty) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  /// 获取时间分割线（同一天的消息只显示一次日期）
  Map<int, bool> getDateHeaderFlags() {
    final Map<int, bool> showHeaderMap = {};
    String? lastDate;
    
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final dateTime = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
      final currentDate = '${dateTime.year}-${dateTime.month}-${dateTime.day}';
      
      // 如果日期与上一条消息不同，显示日期头
      if (lastDate != currentDate) {
        showHeaderMap[i] = true;
        lastDate = currentDate;
      } else {
        showHeaderMap[i] = false;
      }
    }
    
    return showHeaderMap;
  }
} 
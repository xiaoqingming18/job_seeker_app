import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/im_message_model.dart';
import '../../../models/im_conversation_model.dart';
import '../../../services/im_service.dart';
import '../../../services/api/im_api_service.dart';

/// 聊天详情控制器
class ChatDetailController extends GetxController {
  // IM服务
  final ImService _imService = Get.find<ImService>();
  
  // API服务
  final ImApiService _imApiService = ImApiService();
  
  // 图片选择器
  final ImagePicker _imagePicker = ImagePicker();
  
  // 会话ID
  final int conversationId;
  
  // 目标用户ID（单聊时使用）
  final int targetUserId;
  
  // 是否群聊
  final bool isGroup;
  
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
  final RxBool isUploadingMedia = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  
  // 是否显示发送按钮（输入框有内容时显示）
  final RxBool showSendButton = false.obs;
  
  // 当前用户ID
  int? get currentUserId => _imService.currentUserId.value;
  
  // 构造函数，需要传入会话ID、目标用户ID和是否群聊
  ChatDetailController({
    required this.conversationId,
    required this.targetUserId,
    required this.isGroup,
  });
  
  @override
  void onInit() {
    super.onInit();
    print('初始化聊天页面: 会话ID=$conversationId, 目标用户ID=$targetUserId, 是否群聊=$isGroup');
    
    // 加载会话信息
    _loadConversation();
    
    // 加载消息列表
    _loadMessages();
    
    // 监听消息输入变化
    messageController.addListener(_onMessageInputChanged);
    
    // 监听新消息通知
    _setupNewMessageListener();
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
  
  /// 发送消息
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;
    
    if (currentUserId == null) {
      Get.snackbar('错误', '未获取到用户ID，无法发送消息');
      return;
    }
    
    isSending.value = true;
    
    try {
      // 使用ImService发送消息
      await _imService.sendMessage(
        isGroup ? conversationId : targetUserId, 
        messageText, 
        messageType: 'text',
        isGroup: isGroup,
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
  
  /// 选择图片
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // 可以设置图片质量，减小文件大小
      );
      
      if (pickedFile == null) return;
      
      // 显示上传进度
      isUploadingMedia.value = true;
      
      // 发送图片消息
      await _imService.sendMediaMessage(
        targetUserId,
        File(pickedFile.path),
        'image',
        isGroup: isGroup,
        conversationId: conversationId,
        onProgress: (progress) {
          uploadProgress.value = progress;
        }
      );
      
      isUploadingMedia.value = false;
      uploadProgress.value = 0.0;
      
      // 滚动到底部
      _scrollToBottom();
    } catch (e) {
      isUploadingMedia.value = false;
      print('选择图片失败: $e');
      Get.snackbar('错误', '发送图片失败: $e');
    }
  }
  
  /// 选择视频
  Future<void> pickVideo() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // 最大视频时长
      );
      
      if (pickedFile == null) return;
      
      // 显示上传进度
      isUploadingMedia.value = true;
      
      // 发送视频消息
      await _imService.sendMediaMessage(
        targetUserId,
        File(pickedFile.path),
        'video',
        isGroup: isGroup,
        conversationId: conversationId,
        onProgress: (progress) {
          uploadProgress.value = progress;
        }
      );
      
      isUploadingMedia.value = false;
      uploadProgress.value = 0.0;
      
      // 滚动到底部
      _scrollToBottom();
    } catch (e) {
      isUploadingMedia.value = false;
      print('选择视频失败: $e');
      Get.snackbar('错误', '发送视频失败: $e');
    }
  }
} 
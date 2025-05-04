import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_detail_controller.dart';
import '../../../models/im_message_model.dart';
import 'dart:io';

class ChatDetailView extends GetView<ChatDetailController> {
  const ChatDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.conversation.value?.name ?? '聊天',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 显示更多操作菜单
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 消息列表
              Expanded(
                child: _buildMessageList(),
              ),
              // 底部输入框
              _buildInputArea(),
            ],
          ),
          // 上传进度指示器
          Obx(() => controller.isUploadingMedia.value
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: controller.uploadProgress.value,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '上传中...${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // 构建消息列表
  Widget _buildMessageList() {
    return Obx(() {
      if (controller.isLoading.value && controller.messages.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.messages.isEmpty) {
        return const Center(
          child: Text('暂无消息，发送一条消息开始聊天吧'),
        );
      }

      // 获取日期分割线标记
      final dateHeaderFlags = controller.getDateHeaderFlags();

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          final isMyMessage = message.senderId == controller.currentUserId;

          // 构建消息气泡
          return Column(
            children: [
              // 日期头部
              if (dateHeaderFlags[index] == true)
                _buildDateHeader(message.timestamp),
              
              // 消息气泡
              _buildMessageBubble(message, isMyMessage),
            ],
          );
        },
      );
    });
  }

  // 构建日期头部
  Widget _buildDateHeader(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    String dateText;
    if (dateTime.year == now.year && 
        dateTime.month == now.month && 
        dateTime.day == now.day) {
      dateText = '今天';
    } else if (dateTime.year == now.year && 
               dateTime.month == now.month && 
               dateTime.day == now.day - 1) {
      dateText = '昨天';
    } else {
      dateText = '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // 构建消息气泡
  Widget _buildMessageBubble(ImMessageModel message, bool isMyMessage) {
    // 调试日志
    print('构建消息气泡: ID=${message.id}, 类型=${message.messageType}, 内容=${message.content}, URL=${message.mediaUrl}');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧头像(仅接收消息显示)
          if (!isMyMessage) 
            _buildAvatar(message.sender?.avatar),
          
          // 消息内容
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isMyMessage ? 64 : 8,
                right: isMyMessage ? 8 : 64,
              ),
              child: Column(
                crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // 发送者名称(仅接收消息显示)
                  if (!isMyMessage && controller.conversation.value?.isGroup == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        message.senderName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  
                  // 消息气泡
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMyMessage ? Colors.blue[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // 根据消息类型显示不同内容
                        if (message.messageType == 'image')
                          _buildImageMessage(message)
                        else if (message.messageType == 'video')
                          _buildVideoMessage(message)
                        else
                          // 文本消息
                          Text(
                            message.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                        
                        // 时间
                        const SizedBox(height: 4),
                        Text(
                          message.formattedTime,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 右侧头像(仅发送消息显示)
          if (isMyMessage) 
            _buildAvatar(null),
        ],
      ),
    );
  }

  // 构建头像
  Widget _buildAvatar(String? avatar) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.teal[100],
        shape: BoxShape.circle,
      ),
      child: avatar != null && avatar.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  color: Colors.teal,
                ),
              ),
            )
          : const Icon(
              Icons.person,
              color: Colors.teal,
            ),
    );
  }

  // 构建底部输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 更多功能按钮
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.grey[600],
              onPressed: () {
                // 显示更多功能选项
                _showMoreFunctions(Get.context!);
              },
            ),
            
            // 输入框
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: InputBorder.none,
                  ),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ),
            
            // 发送按钮
            Obx(() => controller.showSendButton.value
                ? IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: controller.isSending.value
                        ? null
                        : controller.sendMessage,
                  )
                : IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    color: Colors.grey[600],
                    onPressed: () {
                      // TODO: 显示表情选择器
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示更多功能选项
  void _showMoreFunctions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            _buildFunctionItem(Icons.image, '图片', () {
              Get.back();
              controller.pickImage();
            }),
            _buildFunctionItem(Icons.videocam, '视频', () {
              Get.back();
              controller.pickVideo();
            }),
            _buildFunctionItem(Icons.mic, '语音', () {
              Get.back();
              // 语音消息暂未实现
              Get.snackbar('提示', '语音消息功能正在开发中');
            }),
          ],
        ),
      ),
    );
  }

  // 构建功能项
  Widget _buildFunctionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 显示更多操作菜单
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('会话信息'),
            onTap: () {
              Get.back();
              // TODO: 显示会话信息
            },
          ),
          if (controller.conversation.value?.isGroup == true)
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('群组成员'),
              onTap: () {
                Get.back();
                // TODO: 显示群组成员
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('清空聊天记录'),
            onTap: () {
              Get.back();
              // 显示确认对话框
              Get.dialog(
                AlertDialog(
                  title: const Text('清空聊天记录'),
                  content: const Text('确定要清空与该联系人的所有聊天记录吗？此操作不可撤销。'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        // TODO: 清空聊天记录
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建图片消息
  Widget _buildImageMessage(ImMessageModel message) {
    print('构建图片消息，URL=${message.mediaUrl}');
    
    // 处理媒体URL可能的情况
    String? imageUrl = message.mediaUrl;
    
    // 媒体URL为空或者长度过短（无效）时显示错误提示
    if (imageUrl == null || imageUrl.length < 10) {
      print('无效的图片URL: $imageUrl');
      return Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.red[300], size: 32),
            const SizedBox(height: 8),
            const Text('图片加载失败', style: TextStyle(color: Colors.grey)),
            if (imageUrl != null) Text(
              imageUrl.length > 20 ? '${imageUrl.substring(0, 20)}...' : imageUrl,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    
    // 如果是本地文件路径，转换为File对象
    if (imageUrl.startsWith('/') || imageUrl.startsWith('file://') || 
        (imageUrl.length > 1 && imageUrl[1] == ':')) {
      // 本地文件
      print('检测到本地文件路径: $imageUrl');
      return GestureDetector(
        onTap: () {
          // 查看大图...
        },
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('本地图片加载失败: $error');
                return Container(
                  width: 150,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
        ),
      );
    }
    
    // 标准网络图片URL
    return GestureDetector(
      onTap: () {
        // 点击查看大图
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('图片加载失败: $error, URL: $imageUrl');
                        return Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error, color: Colors.red[300], size: 48),
                              const SizedBox(height: 8),
                              const Text('图片加载失败'),
                              const SizedBox(height: 8),
                              Text('URL: $imageUrl', 
                                style: const TextStyle(fontSize: 10),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 150,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('关闭'),
                ),
              ],
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 150,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  print('图片缩略图加载失败: $error, URL: $imageUrl');
                  return Container(
                    width: 150,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 28),
                          const SizedBox(height: 4),
                          const Text('图片加载失败', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 150,
                    height: 120,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 失败状态覆盖层
          if (message.status == 'failed')
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 24),
                      const SizedBox(height: 4),
                      const Text(
                        '发送失败',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建视频消息
  Widget _buildVideoMessage(ImMessageModel message) {
    return GestureDetector(
      onTap: () {
        // 点击播放视频
        Get.snackbar('提示', '视频播放功能正在开发中');
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white70),
                  ),
                ),
                if (message.status == 'failed')
                  Container(
                    width: 180,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red[300], size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          '发送失败',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '点击播放视频',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
} 
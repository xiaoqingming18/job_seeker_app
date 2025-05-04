import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_detail_controller.dart';
import '../../../models/im_message_model.dart';

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
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _buildMessageList(),
          ),
          // 底部输入框
          _buildInputArea(),
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
                        // 消息内容
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
              // TODO: 选择图片
            }),
            _buildFunctionItem(Icons.camera_alt, '拍照', () {
              Get.back();
              // TODO: 拍照
            }),
            _buildFunctionItem(Icons.videocam, '视频', () {
              Get.back();
              // TODO: 选择视频
            }),
            _buildFunctionItem(Icons.mic, '语音', () {
              Get.back();
              // TODO: 录制语音
            }),
            _buildFunctionItem(Icons.attach_file, '文件', () {
              Get.back();
              // TODO: 选择文件
            }),
            _buildFunctionItem(Icons.location_on, '位置', () {
              Get.back();
              // TODO: 发送位置
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
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resume_list_controller.dart';

class ResumeListView extends GetView<ResumeListController> {
  const ResumeListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的简历'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Obx(() {
        // 处理加载状态
        if (controller.isLoading.value && controller.resumeList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 处理错误状态
        if (controller.hasError.value && controller.resumeList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  '获取简历列表失败: ${controller.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.onRefresh,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        // 显示简历列表
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: Stack(
            children: [
              // 空状态
              if (controller.resumeList.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Colors.grey,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '您还没有创建简历',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '创建简历以便更快地申请职位',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showCreateResumeOptions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          '创建简历',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              // 有数据状态
              else
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.resumeList.length,
                  itemBuilder: (context, index) {
                    final resume = controller.resumeList[index];
                    return _buildResumeItem(resume);
                  },
                ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        // 只有当列表不为空时才显示浮动按钮
        if (controller.resumeList.isNotEmpty) {
          return FloatingActionButton(
            onPressed: _showCreateResumeOptions,
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  // 构建简历项
  Widget _buildResumeItem(dynamic resume) {
    // 判断简历类型
    final isOnlineResume = resume.type == 'online';
    final isDefault = resume.isDefault == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (isOnlineResume) {
            controller.viewOnlineResume(resume.id!);
          } else {
            controller.viewAttachmentResume(resume.id!);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Expanded(
                    child: Text(
                      resume.title ?? '未命名简历',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: const Text(
                        '默认',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 简历类型和更新时间
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOnlineResume
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isOnlineResume ? '在线简历' : '附件简历',
                      style: TextStyle(
                        color: isOnlineResume ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '更新于 ${_formatDate(resume.updateTime)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 编辑按钮（仅在线简历显示）
                  if (isOnlineResume)
                    OutlinedButton(
                      onPressed: () => controller.editOnlineResume(resume.id!),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('编辑'),
                    ),
                  const SizedBox(width: 8),
                  
                  // 设为默认按钮（非默认简历显示）
                  if (!isDefault)
                    OutlinedButton(
                      onPressed: () => controller.setDefaultResume(resume.id!),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('设为默认'),
                    ),
                  const SizedBox(width: 8),
                  
                  // 删除按钮
                  OutlinedButton(
                    onPressed: () => controller.deleteResume(resume.id!),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('删除'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示创建简历选项
  void _showCreateResumeOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '选择简历类型',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.edit_document, color: Colors.white),
              ),
              title: const Text('创建在线简历'),
              subtitle: const Text('逐步填写个人信息、工作经历等'),
              onTap: () {
                Get.back();
                controller.createOnlineResume();
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.upload_file, color: Colors.white),
              ),
              title: const Text('上传附件简历'),
              subtitle: const Text('上传已有的PDF、Word等格式简历'),
              onTap: () {
                Get.back();
                controller.createAttachmentResume();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // 格式化日期
  String _formatDate(String? dateString) {
    if (dateString == null) return '未知';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return '今天';
      } else if (difference.inDays == 1) {
        return '昨天';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}天前';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months个月前';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years年前';
      }
    } catch (e) {
      return dateString;
    }
  }
} 
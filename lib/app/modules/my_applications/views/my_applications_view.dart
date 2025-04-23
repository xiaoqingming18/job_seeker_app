import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_applications_controller.dart';
import '../../../models/job_application_list_model.dart';

class MyApplicationsView extends GetView<MyApplicationsController> {
  const MyApplicationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的申请'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          )
        ],
      ),
      body: Obx(() {
        // 处理加载状态
        if (controller.isLoading.value && controller.applications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 处理错误状态
        if (controller.hasError.value && controller.applications.isEmpty) {
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
                  '获取申请列表失败: ${controller.errorMessage}',
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

        // 处理数据为空的情况
        if (controller.applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  color: Colors.grey,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.selectedStatus.value == null 
                    ? '您还没有提交过申请'
                    : '没有${controller.statusOptions.firstWhere((option) => option['value'] == controller.selectedStatus.value)['label']}的记录',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '去浏览职位并提交申请吧',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // 显示申请列表
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.applications.length + 1, // 添加底部加载更多项
            itemBuilder: (context, index) {
              // 底部加载更多
              if (index == controller.applications.length) {
                // 如果还有更多数据，显示加载更多按钮
                if (controller.currentPage.value < controller.totalPages.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: InkWell(
                        onTap: controller.onLoadMore,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('加载更多'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_downward, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (controller.totalPages.value > 1) {
                  // 已经加载完所有页面，显示没有更多数据
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        '- 没有更多数据了 -',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                } else {
                  // 只有一页数据，不显示额外内容
                  return const SizedBox.shrink();
                }
              }

              // 显示申请项
              final application = controller.applications[index];
              return _buildApplicationItem(application);
            },
          ),
        );
      }),
    );
  }

  // 构建单个申请项
  Widget _buildApplicationItem(JobApplicationItem application) {
    // 解析状态颜色
    final statusColor = _parseColor(application.getStatusColor());
    
    // 解析创建时间
    final createTime = _formatTime(application.createTime);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.viewApplicationDetail(application.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和状态
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      application.demandTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      application.getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 薪资和时间信息
              Row(
                children: [
                  if (application.expectedSalary != null)
                    Text(
                      '${application.expectedSalary!.toStringAsFixed(0)}元/天',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    createTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 入职日期
              if (application.expectedEntryDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '预期入职: ${_formatDate(application.expectedEntryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 8),
              
              // 查看详情按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => controller.viewApplicationDetail(application.id),
                    child: Row(
                      children: const [
                        Text('查看详情'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示筛选对话框
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('筛选申请状态'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.statusOptions.length,
              itemBuilder: (context, index) {
                final option = controller.statusOptions[index];
                final isSelected = controller.selectedStatus.value == option['value'];
                
                return ListTile(
                  title: Text(option['label'] as String),
                  trailing: isSelected 
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                  onTap: () {
                    // 选择状态并关闭对话框
                    controller.changeStatus(option['value'] as String?);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
  
  // 解析颜色代码
  Color _parseColor(String colorCode) {
    // 移除#号并解析
    final code = colorCode.replaceAll('#', '');
    return Color(int.parse('FF$code', radix: 16));
  }
  
  // 格式化日期
  String _formatDate(String date) {
    if (date.length >= 10) {
      return date.substring(0, 10);
    }
    return date;
  }
  
  // 格式化时间
  String _formatTime(String dateTime) {
    try {
      // 尝试解析ISO格式的日期时间
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(dt);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}年前';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}个月前';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      // 如果解析失败，直接返回原始字符串
      return dateTime;
    }
  }
} 
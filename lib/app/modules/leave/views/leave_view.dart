import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/leave_model.dart';
import '../controllers/leave_controller.dart';
import 'leave_form_view.dart';

class LeaveView extends GetView<LeaveController> {
  const LeaveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 在视图构建时确保数据加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 强制刷新数据，不论列表是否为空
      print('请假管理页面: 视图已构建，强制刷新数据');
      controller.refreshLeaveRecords();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('请假管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshLeaveRecords,
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.leaveRecords.isEmpty
                  ? _buildEmptyView()
                  : _buildLeaveListView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const LeaveFormView()),
        child: const Icon(Icons.add),
        tooltip: '申请请假',
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无请假记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右下角按钮申请请假',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshLeaveRecords,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveListView() {
    return controller.obx(
      (data) => ListView.builder(
        itemCount: controller.leaveRecords.length + (controller.isMoreLoading.value ? 1 : 0),
        itemBuilder: (context, index) {
          // 检查是否达到列表底部，需要加载更多
          if (index == controller.leaveRecords.length - 1 && controller.currentPage.value < controller.totalPages.value) {
            // 触发加载更多
            controller.loadMore();
          }

          // 处理正在加载更多的情况
          if (index == controller.leaveRecords.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // 渲染请假记录卡片
          final leave = controller.leaveRecords[index];
          return _buildLeaveCard(leave, context);
        },
      ),
      onEmpty: _buildEmptyView(),
      onError: (error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: $error',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshLeaveRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard(dynamic leave, BuildContext context) {
    final startDate = controller.formatDate(leave.startTime);
    final endDate = controller.formatDate(leave.endTime);
    final statusColor = controller.getLeaveStatusColor(leave.status);
    final statusName = controller.getLeaveStatusName(leave.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.getLeaveTypeName(leave.type),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '项目: ${leave.projectName ?? '未知项目'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '时间: $startDate 至 $endDate',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '原因: ${leave.reason}',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '申请时间: ${leave.createTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(leave.createTime!) : '未知'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (leave.status == LeaveStatus.pending)
                  OutlinedButton(
                    onPressed: () => _showCancelDialog(context, leave.id),
                    child: const Text('取消申请'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选请假记录'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 项目选择
                Obx(() => DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: '项目'),
                      value: controller.selectedProjectId.value,
                      items: controller.projects
                          .map((project) => DropdownMenuItem<int>(
                                value: project.projectId,
                                child: Text(project.projectName ?? '未知项目'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        controller.selectedProjectId.value = value;
                      },
                    )),
                const SizedBox(height: 16),

                // 状态选择
                Obx(() => DropdownButtonFormField<LeaveStatus?>(
                      decoration: const InputDecoration(labelText: '状态'),
                      value: controller.selectedStatus.value,
                      items: controller.leaveStatusList
                          .map((statusData) => DropdownMenuItem<LeaveStatus?>(
                                value: statusData['status'] as LeaveStatus?,
                                child: Text(statusData['name'] as String),
                              ))
                          .toList(),
                      onChanged: (value) {
                        controller.selectedStatus.value = value;
                      },
                    )),
                const SizedBox(height: 16),

                // 开始日期选择
                ListTile(
                  title: const Text('开始日期'),
                  subtitle: Obx(() => Text(
                        controller.startDate.value != null
                            ? controller.formatDate(controller.startDate.value)
                            : '选择日期',
                      )),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.startDate.value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.startDate.value = date;
                    }
                  },
                ),
                const SizedBox(height: 8),

                // 结束日期选择
                ListTile(
                  title: const Text('结束日期'),
                  subtitle: Obx(() => Text(
                        controller.endDate.value != null
                            ? controller.formatDate(controller.endDate.value)
                            : '选择日期',
                      )),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.endDate.value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.endDate.value = date;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.resetFilter();
              Navigator.of(context).pop();
            },
            child: const Text('重置'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.applyFilter();
              Navigator.of(context).pop();
            },
            child: const Text('应用'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, int? leaveId) {
    if (leaveId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消请假申请'),
        content: const Text('确定要取消此请假申请吗？取消后不可恢复。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.cancelLeaveRequest(leaveId);
            },
            child: const Text('确定取消'),
          ),
        ],
      ),
    );
  }
} 
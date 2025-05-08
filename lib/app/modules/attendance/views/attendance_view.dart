import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/attendance_model.dart';
import 'package:job_seeker_app/app/modules/attendance/controllers/attendance_controller.dart';
import 'package:job_seeker_app/app/modules/attendance/views/check_dialog.dart';
import 'package:job_seeker_app/app/modules/attendance/views/filter_widget.dart';
import 'package:job_seeker_app/app/modules/attendance/views/statistics_widget.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('考勤管理'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshRecords,
        child: Column(
          children: [
            // 顶部考勤打卡区域
            _buildCheckInOutArea(),
            
            // 考勤内容区域
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                child: Obx(() {
                  if (controller.isLoading.value && controller.attendanceRecords.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 筛选器
                      AttendanceFilterWidget(controller: controller),
                      const SizedBox(height: 16),
                      
                      // 考勤统计
                      if (controller.statistics.value != null)
                        Obx(() => AttendanceStatisticsWidget(
                          statistics: controller.statistics.value!,
                        )),
                      
                      const SizedBox(height: 16),
                      
                      // 考勤记录列表
                      _buildAttendanceRecords(),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建签到签退区域
  Widget _buildCheckInOutArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 日期和时间显示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 显示当前日期
              Text(
                DateFormat('yyyy年MM月dd日').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // 显示星期几
              Text(
                _getWeekdayName(DateTime.now().weekday),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 打卡按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 签到按钮
              Obx(() => _buildCheckButton(
                title: '签到',
                time: controller.hasCheckedInToday.value ? '已签到' : '未签到',
                isActive: !controller.hasCheckedInToday.value && controller.projects.isNotEmpty,
                icon: Icons.login,
                onTap: () => _showCheckDialog(isCheckIn: true),
              )),
              
              // 签退按钮
              Obx(() => _buildCheckButton(
                title: '签退',
                time: controller.hasCheckedOutToday.value ? '已签退' : '未签退',
                isActive: controller.hasCheckedInToday.value && !controller.hasCheckedOutToday.value && controller.projects.isNotEmpty,
                icon: Icons.logout,
                onTap: () => _showCheckDialog(isCheckIn: false),
              )),
            ],
          ),
          
          // 项目加载中或无项目提示
          Obx(() {
            if (controller.isProjectsLoading.value) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ),
                    SizedBox(width: 8),
                    Text('正在加载项目信息...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            } else if (controller.projects.isEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                child: const Text(
                  '您当前没有参与任何项目，无法进行考勤打卡',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
  
  // 构建打卡按钮
  Widget _buildCheckButton({
    required String title,
    required String time,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isActive ? onTap : null,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.blue.withOpacity(0.8) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 显示签到签退对话框
  void _showCheckDialog({required bool isCheckIn}) {
    if (controller.projects.isEmpty) {
      Get.snackbar(
        '无法打卡',
        '您当前没有参与任何项目，无法进行考勤打卡',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    Get.dialog(
      CheckDialog(
        isCheckIn: isCheckIn,
        projects: controller.projects,
      ),
    );
  }
  
  // 构建考勤记录列表
  Widget _buildAttendanceRecords() {
    return Obx(() {
      if (controller.attendanceRecords.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: const Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '没有找到考勤记录',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '考勤记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '共${controller.totalItems}条记录',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.attendanceRecords.map((record) => _buildAttendanceItem(record)).toList(),
          
          // 加载更多
          if (controller.currentPage.value < controller.totalPages.value)
            InkWell(
              onTap: controller.isMoreLoading.value ? null : controller.loadMoreRecords,
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: controller.isMoreLoading.value
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('加载更多'),
              ),
            ),
        ],
      );
    });
  }
  
  // 构建考勤记录项
  Widget _buildAttendanceItem(AttendanceModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目名称和日期
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  record.projectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: controller.getStatusColor(record.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.statusDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: controller.getStatusColor(record.status),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 打卡时间
          Row(
            children: [
              _buildTimeItem('签到', record.checkInTime),
              const SizedBox(width: 24),
              _buildTimeItem('签退', record.checkOutTime),
              const Spacer(),
              if (record.workHours != null)
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${record.workHours!.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          if (record.remarks != null && record.remarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              '备注: ${record.remarks}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
  
  // 构建时间项
  Widget _buildTimeItem(String label, DateTime? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time != null ? DateFormat('HH:mm').format(time) : '--:--',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // 获取星期几名称
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return '星期一';
      case 2:
        return '星期二';
      case 3:
        return '星期三';
      case 4:
        return '星期四';
      case 5:
        return '星期五';
      case 6:
        return '星期六';
      case 7:
        return '星期日';
      default:
        return '';
    }
  }
} 
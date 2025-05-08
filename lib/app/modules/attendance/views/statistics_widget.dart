import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_seeker_app/app/models/attendance_statistics_model.dart';

class AttendanceStatisticsWidget extends StatelessWidget {
  final AttendanceStatisticsModel statistics;
  
  const AttendanceStatisticsWidget({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('考勤统计'),
          const SizedBox(height: 16),
          
          // 出勤率统计
          _buildAttendanceRate(),
          const SizedBox(height: 16),
          
          // 考勤详细统计
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatItem('总天数', statistics.totalDays.toString(), Colors.blue),
              _buildStatItem('工作日', statistics.workDays.toString(), Colors.indigo),
              _buildStatItem('出勤天数', statistics.attendanceDays.toString(), Colors.green),
              _buildStatItem('正常', statistics.normalDays.toString(), Colors.teal),
              _buildStatItem('迟到', statistics.lateDays.toString(), Colors.orange),
              _buildStatItem('早退', statistics.earlyLeaveDays.toString(), Colors.amber),
              _buildStatItem('缺勤', statistics.absenceDays.toString(), Colors.red),
              _buildStatItem('请假', statistics.leaveDays.toString(), Colors.purple),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          
          // 工作时长统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWorkHoursItem('总工时', '${statistics.totalWorkHours.toStringAsFixed(1)}h'),
              _buildWorkHoursItem('日平均', '${statistics.averageDailyHours.toStringAsFixed(1)}h/天'),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建标题
  Widget _buildSectionTitle(String title) {
    return Row(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // 构建出勤率统计
  Widget _buildAttendanceRate() {
    Color rateColor;
    if (statistics.attendanceRate >= 90) {
      rateColor = Colors.green;
    } else if (statistics.attendanceRate >= 70) {
      rateColor = Colors.orange;
    } else {
      rateColor = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '出勤率',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                statistics.attendanceRate.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: rateColor,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  fontSize: 14,
                  color: rateColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建统计项
  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建工作时长统计项
  Widget _buildWorkHoursItem(String label, String value) {
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 
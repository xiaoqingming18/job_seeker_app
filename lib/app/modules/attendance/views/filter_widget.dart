import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/project_member_model.dart';
import 'package:job_seeker_app/app/modules/attendance/controllers/attendance_controller.dart';

class AttendanceFilterWidget extends StatelessWidget {
  final AttendanceController controller;
  
  const AttendanceFilterWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // 日期范围选择
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildDateSelector(
                  context: context,
                  label: '开始日期',
                  date: controller.startDate.value,
                  onTap: () => _selectDate(
                    context,
                    controller.startDate.value ?? DateTime.now(),
                    isStart: true,
                  ),
                )),
              ),
              const SizedBox(width: 8),
              const Text('至'),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => _buildDateSelector(
                  context: context,
                  label: '结束日期',
                  date: controller.endDate.value,
                  onTap: () => _selectDate(
                    context,
                    controller.endDate.value ?? DateTime.now(),
                    isStart: false,
                  ),
                )),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 项目和状态筛选
          Row(
            children: [
              // 项目筛选
              Expanded(
                child: Obx(() => _buildProjectDropdown(
                  projects: controller.projects,
                  value: controller.selectedProjectId.value,
                  isLoading: controller.isProjectsLoading.value,
                  onChanged: (value) {
                    controller.updateFilter(projectId: value);
                  },
                )),
              ),
              
              const SizedBox(width: 12),
              
              // 状态筛选
              Expanded(
                child: Obx(() => _buildDropdown(
                  items: controller.statusList,
                  value: controller.selectedStatus.value,
                  valueKey: 'code',
                  onChanged: (value) {
                    controller.updateFilter(status: value);
                  },
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建日期选择器
  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? formatter.format(date) : label,
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }
  
  // 选择日期
  Future<void> _selectDate(BuildContext context, DateTime initialDate, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      if (isStart) {
        controller.updateFilter(newStartDate: picked);
      } else {
        controller.updateFilter(newEndDate: picked);
      }
    }
  }
  
  // 构建项目下拉选择框
  Widget _buildProjectDropdown({
    required List<ProjectMemberModel> projects,
    required int? value,
    required bool isLoading,
    required Function(int?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isLoading
          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButton<int?>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('全部项目', style: TextStyle(fontSize: 14)),
                ),
                ...projects.map((project) {
                  return DropdownMenuItem<int?>(
                    value: project.projectId,
                    child: Text(
                      project.projectName ?? '未知项目',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ],
              onChanged: (newValue) {
                onChanged(newValue);
              },
            ),
    );
  }
  
  // 构建下拉选择框
  Widget _buildDropdown({
    required List<Map<String, dynamic>> items,
    required dynamic value,
    String valueKey = 'id',
    required Function(dynamic) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<dynamic>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: items.map((item) {
          return DropdownMenuItem<dynamic>(
            value: item[valueKey],
            child: Text(
              item['name'] as String,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          onChanged(newValue);
        },
      ),
    );
  }
} 
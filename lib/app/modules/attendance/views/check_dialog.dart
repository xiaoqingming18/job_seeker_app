import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_seeker_app/app/models/project_member_model.dart';
import 'package:job_seeker_app/app/modules/attendance/controllers/attendance_controller.dart';

class CheckDialog extends StatefulWidget {
  final bool isCheckIn;
  final List<ProjectMemberModel> projects;
  
  const CheckDialog({
    Key? key,
    required this.isCheckIn,
    required this.projects,
  }) : super(key: key);

  @override
  State<CheckDialog> createState() => _CheckDialogState();
}

class _CheckDialogState extends State<CheckDialog> {
  final controller = Get.find<AttendanceController>();
  
  // 表单字段
  int? selectedProjectId;
  final remarksController = TextEditingController();
  
  // 表单验证状态
  bool isValid = false;
  
  @override
  void initState() {
    super.initState();
    // 如果项目列表不为空，默认选择第一个项目
    if (widget.projects.isNotEmpty && widget.projects[0].projectId != null) {
      selectedProjectId = widget.projects[0].projectId;
    }
    validateForm();
  }
  
  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }
  
  // 验证表单
  void validateForm() {
    setState(() {
      isValid = selectedProjectId != null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isCheckIn ? '签到' : '签退'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 项目选择下拉框
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: '选择项目',
                border: OutlineInputBorder(),
              ),
              value: selectedProjectId,
              items: widget.projects.map((project) {
                return DropdownMenuItem<int>(
                  value: project.projectId,
                  child: Text(project.projectName ?? '未知项目'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProjectId = value;
                  validateForm();
                });
              },
            ),
            const SizedBox(height: 16),
            
            // 备注输入框
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: '备注（选填）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: isValid ? _handleConfirm : null,
          child: Text(widget.isCheckIn ? '确认签到' : '确认签退'),
        ),
      ],
    );
  }
  
  // 处理确认签到/签退
  void _handleConfirm() {
    if (selectedProjectId == null) return;
    
    if (widget.isCheckIn) {
      controller.checkIn(
        projectId: selectedProjectId!,
        remarks: remarksController.text.isNotEmpty ? remarksController.text : null,
      );
    } else {
      controller.checkOut(
        projectId: selectedProjectId!,
        remarks: remarksController.text.isNotEmpty ? remarksController.text : null,
      );
    }
    
    Get.back();
  }
} 
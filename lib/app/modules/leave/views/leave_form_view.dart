import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/leave_model.dart';
import '../controllers/leave_controller.dart';

class LeaveFormView extends GetView<LeaveController> {
  const LeaveFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('申请请假'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 项目选择
            _buildProjectSelector(),
            const SizedBox(height: 24),

            // 请假类型选择
            _buildLeaveTypeSelector(),
            const SizedBox(height: 24),

            // 请假日期选择
            _buildDateRangeSelector(context),
            const SizedBox(height: 24),

            // 请假原因输入
            _buildReasonInput(),
            const SizedBox(height: 32),

            // 提交按钮
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择项目',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => controller.isProjectsLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.projects.isEmpty
                ? const Text('暂无可选项目，请联系管理员')
                : DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      hintText: '请选择项目',
                    ),
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
      ],
    );
  }

  Widget _buildLeaveTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请假类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<LeaveType>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: '请选择请假类型',
              ),
              value: controller.selectedLeaveType.value,
              items: controller.leaveTypeList
                  .map((typeData) => DropdownMenuItem<LeaveType>(
                        value: typeData['type'] as LeaveType,
                        child: Text(typeData['name'] as String),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedLeaveType.value = value;
                }
              },
            )),
      ],
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请假时间',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, isStart: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            DateFormat('yyyy-MM-dd').format(controller.newLeaveStartDate.value),
                            style: const TextStyle(fontSize: 16),
                          )),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('至'),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, isStart: false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            DateFormat('yyyy-MM-dd').format(controller.newLeaveEndDate.value),
                            style: const TextStyle(fontSize: 16),
                          )),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final start = controller.newLeaveStartDate.value;
          final end = controller.newLeaveEndDate.value;
          final difference = end.difference(start).inDays + 1;
          return Text(
            '共 $difference 天',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          );
        }),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final initialDate = isStart ? controller.newLeaveStartDate.value : controller.newLeaveEndDate.value;
    final minDate = isStart ? DateTime.now() : controller.newLeaveStartDate.value;
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (selectedDate != null) {
      if (isStart) {
        controller.newLeaveStartDate.value = selectedDate;
        // 如果结束日期早于开始日期，调整结束日期
        if (controller.newLeaveEndDate.value.isBefore(selectedDate)) {
          controller.newLeaveEndDate.value = selectedDate;
        }
      } else {
        controller.newLeaveEndDate.value = selectedDate;
      }
    }
  }

  Widget _buildReasonInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请假原因',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.reasonController,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '请输入请假原因',
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    final result = await controller.submitLeaveRequest();
                    if (result) {
                      // 显示成功对话框，然后返回
                      showDialog(
                        context: Get.context!,
                        barrierDismissible: false, // 用户必须点击按钮关闭
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 10),
                                const Text('申请成功'),
                              ],
                            ),
                            content: const Text('您的请假申请已成功提交，请等待审批。'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // 关闭对话框
                                  Get.back(); // 返回列表页
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
            child: controller.isSubmitting.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    '提交申请',
                    style: TextStyle(fontSize: 16),
                  ),
          )),
    );
  }
} 
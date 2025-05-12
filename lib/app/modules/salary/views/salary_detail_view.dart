import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/salary_detail_controller.dart';
import '../../../models/salary_model.dart';

class SalaryDetailView extends GetView<SalaryDetailController> {
  const SalaryDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工资详情'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.retry,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (controller.salary.value == null) {
          return const Center(
            child: Text('无法获取工资详情'),
          );
        }

        final salary = controller.salary.value!;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部摘要卡片
              _buildSummaryCard(salary),
              
              // 明细项标题
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '工资明细',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // 明细项列表
              if (salary.items != null && salary.items!.isNotEmpty)
                ...salary.items!.map((item) => _buildSalaryItemCard(item)).toList()
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      '暂无工资明细',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // 头部摘要卡片
  Widget _buildSummaryCard(SalaryModel salary) {
    // 获取状态颜色
    Color statusColor;
    switch (salary.status) {
      case 'pending':
        statusColor = const Color(0xFFFFA000); // 橙色
        break;
      case 'confirmed':
        statusColor = const Color(0xFF2196F3); // 蓝色
        break;
      case 'paid':
        statusColor = const Color(0xFF4CAF50); // 绿色
        break;
      default:
        statusColor = const Color(0xFF9E9E9E); // 灰色
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${salary.year}年${salary.month}月工资单',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    salary.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 项目信息
            Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '项目：${salary.projectName ?? '未知项目'}',
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 工作天数
            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '工作天数：${salary.workDays ?? 0} 天',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 分隔线
            const Divider(),
            const SizedBox(height: 16),
            
            // 金额汇总
            _buildAmountRow('基本工资', salary.basicSalary, Colors.blue),
            const SizedBox(height: 8),
            _buildAmountRow('加班费', salary.overtimePay, Colors.orange),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            _buildAmountRow('总金额', salary.totalAmount, Colors.green, isTotal: true),
            
            // 时间信息
            const SizedBox(height: 16),
            if (salary.paymentTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '发放时间：${salary.paymentTime}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '创建时间：${salary.createTime ?? '未知'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 金额行
  Widget _buildAmountRow(String label, double? amount, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          controller.formatAmount(amount),
          style: TextStyle(
            color: color,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  // 工资明细项卡片
  Widget _buildSalaryItemCard(SalaryItemModel item) {
    // 获取项目类型颜色
    Color itemTypeColor;
    switch (item.itemType) {
      case 'attendance':
        itemTypeColor = const Color(0xFF2196F3); // 蓝色
        break;
      case 'overtime':
        itemTypeColor = const Color(0xFFFF9800); // 橙色
        break;
      case 'bonus':
        itemTypeColor = const Color(0xFF4CAF50); // 绿色
        break;
      case 'subsidy':
        itemTypeColor = const Color(0xFF9C27B0); // 紫色
        break;
      case 'deduction':
        itemTypeColor = const Color(0xFFF44336); // 红色
        break;
      default:
        itemTypeColor = const Color(0xFF9E9E9E); // 灰色
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: itemTypeColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和金额
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: itemTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.itemTypeText,
                        style: TextStyle(
                          color: itemTypeColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.itemName ?? '未命名项目',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  controller.formatAmount(item.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.itemType == 'deduction' ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            if (item.quantity != null || item.unitPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (item.quantity != null)
                    Text(
                      '数量: ${item.quantity?.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  if (item.quantity != null && item.unitPrice != null)
                    const Text(' × ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  if (item.unitPrice != null)
                    Text(
                      '单价: ${controller.formatAmount(item.unitPrice)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ],
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 
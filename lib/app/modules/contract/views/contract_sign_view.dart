import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contract_sign_controller.dart';

class ContractSignView extends GetView<ContractSignController> {
  const ContractSignView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('合同签署'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.contractDetail.value == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchContractDetail,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final contract = controller.contractDetail.value;
          if (contract == null) {
            return const Center(
              child: Text('未找到合同信息'),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 合同基本信息卡片
                  _buildInfoCard(
                    title: '合同基本信息',
                    children: [
                      _buildInfoRow('合同编号', contract['contractCode'] ?? '--'),
                      _buildInfoRow('合同模板', contract['templateName'] ?? '--'),
                      _buildInfoRow('合同状态', _getStatusText(contract['status'])),
                      _buildInfoRow('创建时间', _formatDateTime(contract['createTime'])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 项目信息卡片
                  _buildInfoCard(
                    title: '项目信息',
                    children: [
                      _buildInfoRow('项目名称', contract['projectName'] ?? '--'),
                      _buildInfoRow('公司名称', contract['companyName'] ?? '--'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 合同期限卡片
                  _buildInfoCard(
                    title: '合同期限',
                    children: [
                      _buildInfoRow('开始日期', _formatDate(contract['startDate'])),
                      _buildInfoRow('结束日期', _formatDate(contract['endDate'])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 合同内容卡片
                  _buildInfoCard(
                    title: '合同内容',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          contract['contractContent'] ?? '暂无合同内容',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 签署按钮
                  if (contract['status'] == 'unsign')
                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value || controller.isSigned.value
                          ? null
                          : () => controller.signContract(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '确认签署',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
                  // 底部留白
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return '待发起签署';
      case 'unsign':
        return '待签署';
      case 'review':
        return '待审核';
      case 'active':
        return '生效中';
      case 'expired':
        return '已过期';
      case 'terminated':
        return '已终止';
      default:
        return '未知状态';
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '--';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return date;
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '--';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
} 
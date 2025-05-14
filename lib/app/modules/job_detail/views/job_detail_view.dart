import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_detail_controller.dart';

class JobDetailView extends GetView<JobDetailController> {
  const JobDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('职位详情'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Obx(() {
        // 处理加载状态
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 处理错误状态
        if (controller.hasError.value) {
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
                  '获取职位信息失败: ${controller.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshJobDetail,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        // 处理数据为空的情况
        if (controller.jobDetail.value == null) {
          return const Center(
            child: Text('职位信息不存在'),
          );
        }

        // 显示职位详情
        final job = controller.jobDetail.value!;
        return RefreshIndicator(
          onRefresh: controller.refreshJobDetail,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(job),
                _buildInfoSection(job),
                _buildRequirementSection(job),
                _buildCompanySection(job),
                _buildActionButtons(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 构建顶部职位信息区域
  Widget _buildHeaderSection(dynamic job) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${job.dailyWage.toStringAsFixed(0)}元/天',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const Spacer(),
              // 急聘标签
              if (job.status == 'open')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.red[400], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '急聘',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildTag('招${job.headcount}人', Colors.blue[50]!, Colors.blue[700]!),
              _buildTag(job.jobTypeName, Colors.green[50]!, Colors.green[700]!),
              _buildTag(job.jobTypeCategory ?? '未分类', Colors.purple[50]!, Colors.purple[700]!),
              if (job.workHours != null && job.workHours!.isNotEmpty)
                _buildTag(job.workHours!, Colors.orange[50]!, Colors.orange[700]!),
              _buildTag('${_formatDate(job.startDate)} - ${_formatDate(job.endDate)}', Colors.purple[50]!, Colors.purple[700]!),
              if (job.accommodation)
                _buildTag('包住宿', Colors.teal[50]!, Colors.teal[700]!),
              if (job.meals)
                _buildTag('包餐食', Colors.amber[50]!, Colors.amber[700]!),
            ],
          ),
        ],
      ),
    );
  }

  // 构建详细信息区域
  Widget _buildInfoSection(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '工作信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem('工作地点', job.projectAddress ?? '未提供地点信息'),
          _buildInfoItem('项目名称', job.projectName),
          _buildInfoItem('工作时间', job.workHours ?? '未提供工作时间'),
          _buildInfoItem('开始日期', _formatDate(job.startDate)),
          _buildInfoItem('结束日期', _formatDate(job.endDate)),
          _buildInfoItem('食宿条件', _buildAccommodationText(job)),
        ],
      ),
    );
  }

  // 构建工作要求区域
  Widget _buildRequirementSection(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '工作要求',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (job.requirements != null && job.requirements!.isNotEmpty)
            Text(
              job.requirements!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            )
          else
            const Text(
              '暂无特殊要求',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // 构建公司信息区域
  Widget _buildCompanySection(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '公司信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    Icons.business,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.companyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '建筑工程承包商',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.snackbar('提示', '公司详情功能正在开发中...');
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建底部按钮区域
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.snackbar('提示', '收藏功能正在开发中...');
              },
              icon: const Icon(Icons.star_border),
              label: const Text('收藏'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Obx(() => OutlinedButton.icon(
              onPressed: controller.isCreatingConversation.value
                  ? null
                  : () => controller.chatWithProjectManager(),
              icon: controller.isCreatingConversation.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chat_outlined),
              label: const Text('沟通'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.blue,
              ),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => controller.showApplicationForm(),
              icon: const Icon(Icons.send),
              label: const Text('立即申请'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建信息项
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建标签
  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }

  // 构建食宿条件文本
  String _buildAccommodationText(dynamic job) {
    List<String> conditions = [];
    if (job.accommodation) conditions.add('提供住宿');
    if (job.meals) conditions.add('提供餐食');
    
    if (conditions.isEmpty) return '不提供食宿';
    return conditions.join('，');
  }

  // 格式化日期
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '未知日期';
    }
    // 检查日期格式是否已经是 YYYY-MM-DD
    if (date.length >= 10 && date.contains('-')) {
      return date.substring(0, 10); // 只返回 YYYY-MM-DD 部分
    }
    return date; // 如果格式不匹配，返回原始字符串
  }
} 
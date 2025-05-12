import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/performance_detail_controller.dart';

class PerformanceDetailView extends GetView<PerformanceDetailController> {
  const PerformanceDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('绩效评估详情'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadPerformanceDetail,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final performance = controller.performance.value;
        if (performance == null) {
          return const Center(
            child: Text('未找到评估记录'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息
              _buildHeaderCard(context, performance),
              
              const SizedBox(height: 16),
              
              // 分数详情
              _buildScoreCard(context, performance),
              
              const SizedBox(height: 16),
              
              // 评价详情
              _buildEvaluationCard(context, performance),
              
              const SizedBox(height: 16),
              
              // 评估信息
              _buildInfoCard(context, performance),
            ],
          ),
        );
      }),
    );
  }

  // 构建头部信息卡片
  Widget _buildHeaderCard(BuildContext context, dynamic performance) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        performance.projectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '评估周期: ${performance.evaluationPeriod}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: controller.getTotalScoreColor(performance.totalScore),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${performance.totalScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        controller.getScoreRating(performance.totalScore),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('职位', performance.position ?? '无'),
                _buildInfoItem('工种', performance.occupationName ?? '无'),
                _buildInfoItem('姓名', performance.memberName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建信息项
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 构建分数卡片
  Widget _buildScoreCard(BuildContext context, dynamic performance) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '评分详情',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildScoreItem(
              context,
              '工作质量',
              performance.workQualityScore,
              '工作成果的质量、完成度和精确度',
            ),
            const SizedBox(height: 12),
            _buildScoreItem(
              context,
              '工作效率',
              performance.efficiencyScore,
              '完成工作任务的速度和资源利用效率',
            ),
            const SizedBox(height: 12),
            _buildScoreItem(
              context,
              '工作态度',
              performance.attitudeScore,
              '工作责任心、积极性和主动性',
            ),
            const SizedBox(height: 12),
            _buildScoreItem(
              context,
              '团队协作',
              performance.teamworkScore,
              '与团队成员的沟通协作能力',
            ),
          ],
        ),
      ),
    );
  }

  // 构建评分项
  Widget _buildScoreItem(BuildContext context, String label, int score, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: controller.getScoreColor(score),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建评价卡片
  Widget _buildEvaluationCard(BuildContext context, dynamic performance) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '评价详情',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildCommentSection('优点', performance.strengths ?? '无'),
            const SizedBox(height: 12),
            _buildCommentSection('需改进', performance.weaknesses ?? '无'),
            const SizedBox(height: 12),
            _buildCommentSection('综合评语', performance.comments ?? '无'),
          ],
        ),
      ),
    );
  }

  // 构建评价部分
  Widget _buildCommentSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(content),
        ),
      ],
    );
  }

  // 构建信息卡片
  Widget _buildInfoCard(BuildContext context, dynamic performance) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '评估信息',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('评估人', performance.evaluatorName),
            const SizedBox(height: 8),
            _buildInfoRow('评估ID', '#${performance.id}'),
            const SizedBox(height: 8),
            _buildInfoRow('创建时间', controller.formatDate(performance.createTime)),
            const SizedBox(height: 8),
            _buildInfoRow('更新时间', controller.formatDate(performance.updateTime)),
          ],
        ),
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
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
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_seeker_app/app/routes/app_pages.dart';
import '../controllers/performance_controller.dart';

class PerformanceView extends GetView<PerformanceController> {
  const PerformanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('绩效评估'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.performanceList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value && controller.performanceList.isEmpty) {
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
                  onPressed: controller.loadUserProjects,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // 筛选栏
            _buildFilterBar(context),
            
            // 评估记录列表
            Expanded(
              child: controller.performanceList.isEmpty
                  ? _buildEmptyView(context)
                  : _buildPerformanceList(context),
            ),
            
            // 分页控制
            if (controller.performanceList.isNotEmpty)
              _buildPagination(context),
          ],
        );
      }),
    );
  }

  // 构建筛选栏
  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目选择
          Row(
            children: [
              const Text('项目: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => DropdownButton<int>(
                  value: controller.selectedProjectId.value,
                  isExpanded: true,
                  hint: const Text('选择项目'),
                  onChanged: controller.changeProject,
                  items: controller.userProjects.map((project) {
                    return DropdownMenuItem<int>(
                      value: project.projectId,
                      child: Text(
                        project.projectName ?? '未命名项目',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                )),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 评估周期筛选
          Row(
            children: [
              const Text('评估周期: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.periodController,
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM，如2023-06',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearPeriodFilter,
                    ),
                  ),
                  onSubmitted: controller.setPeriodFilter,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.setPeriodFilter(
                  controller.periodController.text,
                ),
                child: const Text('筛选'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建评估记录列表
  Widget _buildPerformanceList(BuildContext context) {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.performanceList.length,
      itemBuilder: (context, index) {
        final performance = controller.performanceList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: InkWell(
            onTap: () => Get.toNamed(
              Routes.PERFORMANCE_DETAIL,
              parameters: {'id': performance.id.toString()},
            ),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${performance.projectName} - ${performance.evaluationPeriod}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: controller.getTotalScoreColor(performance.totalScore),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${performance.totalScore} 分',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreItem('工作质量', performance.workQualityScore),
                      _buildScoreItem('工作效率', performance.efficiencyScore),
                      _buildScoreItem('工作态度', performance.attitudeScore),
                      _buildScoreItem('团队协作', performance.teamworkScore),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 评估人信息
                      Expanded(
                        flex: 2,
                        child: Text(
                          '评估人: ${performance.evaluatorName}',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8), // 添加间距
                      // 评估时间信息
                      Expanded(
                        flex: 3,
                        child: Text(
                          '评估时间: ${controller.formatShortDate(performance.createTime)}',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  // 构建评分项
  Widget _buildScoreItem(String label, int score) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 30,
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
      ],
    );
  }

  // 构建空视图
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assessment_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无绩效评估记录',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            '当您有绩效评估记录时，将在此处显示',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 构建分页控制
  Widget _buildPagination(BuildContext context) {
    final totalPages = (controller.totalItems.value / controller.pageSize.value).ceil();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.currentPage.value > 1
                ? () => controller.goToPage(controller.currentPage.value - 1)
                : null,
          ),
          Text(
            '${controller.currentPage.value} / $totalPages',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: controller.currentPage.value < totalPages
                ? () => controller.goToPage(controller.currentPage.value + 1)
                : null,
          ),
        ],
      ),
    );
  }
} 
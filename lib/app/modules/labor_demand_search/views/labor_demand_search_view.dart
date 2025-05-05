import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/labor_demand_search_controller.dart';
import '../widgets/filter_panel.dart';
import '../../../models/labor_demand_model.dart';

class LaborDemandSearchView extends GetView<LaborDemandSearchController> {
  const LaborDemandSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() => _buildLaborDemandList()),
          ),
        ],
      ),
    );
  }

  // 搜索栏
  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller.searchController,
        focusNode: controller.focusNode,
        decoration: InputDecoration(
          hintText: '搜索工种、项目或地点',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () {
              controller.searchController.clear();
              controller.applySearch();
            },
          ),
        ),
        onSubmitted: (_) => controller.applySearch(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  // 筛选栏
  Widget _buildFilterBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(
                    label: '项目类型',
                    onTap: () {
                      // 显示项目类型筛选面板
                      controller.toggleFilterPanel();
                    },
                    hasValue: controller.selectedProjectType.value != 'all',
                    value: controller.selectedProjectType.value != 'all'
                        ? controller.projectTypeMappings[controller.selectedProjectType.value] ?? '未知'
                        : null,
                  ),
                  _buildFilterButton(
                    label: '工种类别',
                    onTap: () {
                      // 显示工种类别筛选面板
                      controller.toggleFilterPanel();
                    },
                    hasValue: controller.selectedCategoryName.isNotEmpty,
                    value: controller.selectedCategoryName.isEmpty
                        ? null
                        : controller.selectedCategoryName.value,
                  ),
                  _buildFilterButton(
                    label: '工种',
                    onTap: () {
                      // 显示工种筛选面板
                      controller.toggleFilterPanel();
                    },
                    hasValue: controller.selectedOccupationName.isNotEmpty,
                    value: controller.selectedOccupationName.isEmpty
                        ? null
                        : controller.selectedOccupationName.value,
                  ),
                  _buildFilterButton(
                    label: '地点',
                    onTap: () {
                      // 显示地点筛选面板
                      controller.toggleFilterPanel();
                    },
                    hasValue: controller.selectedLocation.isNotEmpty,
                    value: controller.selectedLocation.isEmpty
                        ? null
                        : controller.selectedLocation.value,
                  ),
                ],
              ),
            ),
          ),
          // 重置按钮
          TextButton(
            onPressed: controller.resetFilters,
            child: const Text('重置'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // 筛选按钮
  Widget _buildFilterButton({
    required String label,
    required VoidCallback onTap,
    required bool hasValue,
    String? value,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: hasValue ? const Color(0xFFE3F2FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value ?? label,
              style: TextStyle(
                fontSize: 14,
                color: hasValue ? Colors.blue : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: hasValue ? Colors.blue : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  // 劳务需求列表
  Widget _buildLaborDemandList() {
    // 处理加载状态
    if (controller.isLoading.value && controller.laborDemands.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 处理错误状态
    if (controller.hasError.value && controller.laborDemands.isEmpty) {
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
              '加载失败: ${controller.errorMessage}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.refreshLaborDemands,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 处理空数据状态
    if (controller.laborDemands.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无符合条件的劳务需求',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 显示劳务需求列表
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: controller.refreshLaborDemands,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.laborDemands.length + 1, // +1 为了加载更多按钮
            itemBuilder: (context, index) {
              if (index < controller.laborDemands.length) {
                return _buildLaborDemandCard(controller.laborDemands[index]);
              } else if (controller.currentPage.value < controller.totalPages.value) {
                // 显示加载更多按钮
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : OutlinedButton(
                            onPressed: controller.loadMoreLaborDemands,
                            child: const Text('加载更多'),
                          ),
                  ),
                );
              } else {
                // 已加载全部数据
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '已加载全部数据',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        // 筛选面板
        Obx(() {
          if (controller.isFilterPanelOpen.value) {
            return const Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: FilterPanel(),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  // 劳务需求卡片
  Widget _buildLaborDemandCard(LaborDemandModel demand) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // 跳转到职位详情页
          Get.toNamed('/job-detail', parameters: {'id': demand.id.toString()});
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 项目类型图标
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Icon(
                        _getJobTypeIcon(demand.jobTypeCategory ?? '其他'),
                        color: const Color(0xFF1976D2),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                demand.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${demand.dailyWage.toStringAsFixed(0)}元/天',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${demand.companyName} · ${demand.projectAddress ?? '未知地点'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getProjectTypeIcon(_getProjectType(demand.projectName)),
                              color: Colors.grey[500],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              demand.projectName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // 招聘人数标签
                  _buildTag(
                    '招${demand.headcount}人', 
                    Colors.blue[50]!, 
                    Colors.blue[700]!
                  ),
                  
                  // 工作时间标签
                  _buildTag(
                    demand.workHours ?? '工作时间未知', 
                    Colors.green[50]!, 
                    Colors.green[700]!
                  ),
                  
                  // 工期标签
                  _buildTag(
                    '${_formatDate(demand.startDate)} ~ ${_formatDate(demand.endDate)}', 
                    Colors.purple[50]!, 
                    Colors.purple[700]!
                  ),
                  
                  // 住宿标签
                  if (demand.accommodation)
                    _buildTag(
                      '包住宿', 
                      Colors.orange[50]!, 
                      Colors.orange[700]!
                    ),
                  
                  // 餐食标签
                  if (demand.meals)
                    _buildTag(
                      '包餐食', 
                      Colors.teal[50]!, 
                      Colors.teal[700]!
                    ),
                ],
              ),
            ],
          ),
        ),
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

  // 根据工种类别获取对应图标
  IconData _getJobTypeIcon(String category) {
    switch (category) {
      case '木工': return Icons.handyman;
      case '电工': return Icons.electrical_services;
      case '混凝土工': return Icons.tonality;
      case '钢筋工': return Icons.architecture;
      case '砌筑工': return Icons.domain;
      case '架子工': return Icons.view_column;
      case '管道工': return Icons.plumbing;
      case '焊接工': return Icons.whatshot;
      default: return Icons.construction;
    }
  }

  // 根据项目名称猜测项目类型
  String _getProjectType(String projectName) {
    if (projectName.contains('住宅') || projectName.contains('小区') || projectName.contains('家园') || projectName.contains('公寓')) {
      return '住宅项目';
    } else if (projectName.contains('商业') || projectName.contains('商场') || projectName.contains('办公') || projectName.contains('中心')) {
      return '商业建筑';
    } else if (projectName.contains('工业') || projectName.contains('工厂') || projectName.contains('制造')) {
      return '工业项目';
    } else if (projectName.contains('市政') || projectName.contains('道路') || projectName.contains('桥梁') || projectName.contains('公园')) {
      return '市政工程';
    } else {
      return '商业建筑'; // 默认归类为商业建筑
    }
  }
  
  // 根据项目类型获取对应图标
  IconData _getProjectTypeIcon(String projectType) {
    switch (projectType) {
      case '住宅项目': return Icons.home_work;
      case '商业建筑': return Icons.business;
      case '工业项目': return Icons.factory;
      case '市政工程': return Icons.account_balance;
      default: return Icons.construction;
    }
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
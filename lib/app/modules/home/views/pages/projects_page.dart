import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class ProjectsPage extends GetView<HomeController> {
  const ProjectsPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 整体可滚动的内容区域
          RefreshIndicator(
            onRefresh: () => controller.refreshLaborDemands(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildFeaturedSection(),
                  _buildLaborDemandList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建顶部搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.construction,
                color: Color(0xFF1976D2),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                "建筑劳务招聘",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.blue[700],
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "全国",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue[700],
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索工种、项目或地点',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onTap: () {
                Get.snackbar('提示', '搜索功能正在开发中...');
              },
              readOnly: true, // 防止键盘弹出
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryFilter(),
        ],
      ),
    );
  }

  // 特色工种推荐区域
  Widget _buildFeaturedSection() {
    final featuredJobs = [
      {'name': '砌筑工', 'icon': Icons.domain},
      {'name': '钢筋工', 'icon': Icons.architecture},
      {'name': '架子工', 'icon': Icons.view_column},
      {'name': '木工', 'icon': Icons.handyman},
      {'name': '混凝土工', 'icon': Icons.tonality},
      {'name': '电工', 'icon': Icons.electrical_services},
      {'name': '管道工', 'icon': Icons.plumbing},
      {'name': '焊接工', 'icon': Icons.whatshot},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "热门工种",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  "查看全部",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1976D2),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF1976D2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: featuredJobs.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          featuredJobs[index]['icon'] as IconData,
                          color: const Color(0xFF1976D2),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        featuredJobs[index]['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建分类过滤器
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip("全部", true),
          _buildFilterChip("商业建筑", false),
          _buildFilterChip("住宅项目", false),
          _buildFilterChip("市政工程", false),
          _buildFilterChip("道路桥梁", false),
          _buildFilterChip("装修工程", false),
          _buildFilterChip("其他", false),
        ],
      ),
    );
  }
  
  // 构建过滤标签
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
          ),
        ),
        onSelected: (bool selected) {
          // 过滤功能实现
          Get.snackbar('提示', '分类过滤功能正在开发中...');
        },
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // 构建劳务需求列表
  Widget _buildLaborDemandList() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        // 处理加载状态
        if (controller.isLoading.value && controller.laborDemands.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 处理错误状态
        if (controller.hasError.value && controller.laborDemands.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refreshLaborDemands,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // 处理空数据状态
        if (controller.laborDemands.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                    '暂无劳务需求数据',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }
        
        // 显示劳务需求列表
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '共找到 ${controller.totalItems} 个需求',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                // 可以添加排序功能
                TextButton.icon(
                  onPressed: () {
                    Get.snackbar('提示', '排序功能正在开发中...');
                  },
                  icon: const Icon(Icons.sort, size: 16),
                  label: const Text('工资最高'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...controller.laborDemands.map((demand) => _buildLaborDemandCard(demand)).toList(),
            
            // 加载更多按钮
            if (controller.currentPage.value < controller.totalPages.value)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Obx(() => controller.isLoading.value && controller.laborDemands.isNotEmpty
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: controller.loadMoreLaborDemands,
                        child: const Text('加载更多'),
                      ),
                  ),
                ),
              ),
            
            // 底部留白区域，提高用户体验
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }

  // 构建劳务需求卡片
  Widget _buildLaborDemandCard(dynamic demand) {
    // 根据工种类别获取对应图标
    IconData getJobTypeIcon(String category) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Get.snackbar('提示', '职位详情功能正在开发中...');
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
                        getJobTypeIcon(demand.jobTypeCategory ?? '其他'),
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
                              Icons.business,
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
                    '${demand.startDate.substring(5)} ~ ${demand.endDate.substring(5)}', 
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
              
              // 显示要求信息
              if (demand.requirements != null && demand.requirements!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '要求: ${demand.requirements}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              
              // 显示紧急招聘标签
              if (demand.status == 'open') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.red[400], size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '急聘',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '工期紧急，优先安排入场',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
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
}

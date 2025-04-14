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
          // 背景设计 - 添加建筑行业元素
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              image: const DecorationImage(
                image: AssetImage('assets/images/construction_bg_pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.05, // 透明度很低，作为水印背景
              ),
            ),
          ),
          // 整体可滚动的内容区域
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFeaturedSection(),
                _buildProjectList(),
              ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
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

  // 构建项目列表 - 修改为返回Column而不是带滚动功能的ListView
  Widget _buildProjectList() {
    // 模拟建筑行业劳务职位数据
    final jobs = [
      {
        'title': '高级砌筑工',
        'company': '中建三局工程有限公司',
        'location': '北京·朝阳区',
        'salary': '350-450/天',
        'tags': ['经验3年+', '包吃住', '长期稳定'],
        'projectType': '商业建筑',
        'isUrgent': true,
      },
      {
        'title': '木工/模板工',
        'company': '恒大建筑集团',
        'location': '上海·浦东新区',
        'salary': '400-500/天',
        'tags': ['经验5年+', '包吃住', '月结工资'],
        'projectType': '住宅项目',
        'isUrgent': false,
      },
      {
        'title': '钢筋工班组',
        'company': '华润建筑有限公司',
        'location': '广州·天河区',
        'salary': '380-450/天',
        'tags': ['多人招聘', '提供工具', '长期合作'],
        'projectType': '市政工程',
        'isUrgent': true,
      },
      {
        'title': '电气安装工',
        'company': '中铁建设集团',
        'location': '深圳·南山区',
        'salary': '320-420/天',
        'tags': ['持证上岗', '包住宿', '日结工资'],
        'projectType': '商业建筑',
        'isUrgent': false,
      },
      {
        'title': '水暖安装工',
        'company': '万科物业工程部',
        'location': '杭州·西湖区',
        'salary': '300-380/天',
        'tags': ['经验2年+', '提供工具', '月结工资'],
        'projectType': '住宅项目',
        'isUrgent': true,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          ...jobs.map((job) => _buildJobCard(job)).toList(),
          // 底部留白区域，提高用户体验
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // 构建职位卡片
  Widget _buildJobCard(Map<String, dynamic> job) {
    IconData getProjectTypeIcon(String type) {
      switch (type) {
        case '商业建筑': return Icons.business;
        case '住宅项目': return Icons.home_work;
        case '市政工程': return Icons.account_balance;
        case '道路桥梁': return Icons.add_road;
        case '装修工程': return Icons.brush;
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
                  // 公司Logo或项目类型图标
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Icon(
                        getProjectTypeIcon(job['projectType'] as String),
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
                                job['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              job['salary'] as String,
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
                          '${job['company']} · ${job['location']}',
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
                              getProjectTypeIcon(job['projectType'] as String),
                              color: Colors.grey[500],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job['projectType'] as String,
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
                children: (job['tags'] as List).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (job['isUrgent'] == true) ...[
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
}

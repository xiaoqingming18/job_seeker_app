import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/labor_demand_search_controller.dart';

class FilterPanel extends GetView<LaborDemandSearchController> {
  const FilterPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: controller.toggleFilterPanel,
        child: Stack(
          children: [
            // 筛选面板内容
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {}, // 阻止点击事件冒泡
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 筛选面板标题
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '筛选条件',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      
                      // 项目类型选择
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '项目类型',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.projectTypeMappings.entries.map((entry) {
                                return Obx(() => _buildSelectionChip(
                                  label: entry.value,
                                  isSelected: controller.selectedProjectType.value == entry.key,
                                  onTap: () => controller.selectProjectType(entry.key),
                                ));
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(height: 1),
                      
                      // 工种选择
                      Obx(() {
                        if (controller.isLoadingOccupations.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        if (controller.occupationCategories.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text('暂无工种数据'),
                            ),
                          );
                        }
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '工种选择',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // 工种类别选择
                              SizedBox(
                                height: 36,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _buildCategoryChip(
                                      label: '全部类别',
                                      isSelected: controller.selectedCategoryId.value == null,
                                      onTap: () => controller.selectCategory(null, ''),
                                    ),
                                    ...controller.occupationCategories.map((category) {
                                      return _buildCategoryChip(
                                        label: category.name,
                                        isSelected: controller.selectedCategoryId.value == category.id,
                                        onTap: () => controller.selectCategory(category.id, category.name),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // 工种选择
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildSelectionChip(
                                    label: '全部工种',
                                    isSelected: controller.selectedOccupationId.value == null,
                                    onTap: () => controller.selectOccupation(null, ''),
                                  ),
                                  ...controller.getOccupationsForSelectedCategory().map((occupation) {
                                    return _buildSelectionChip(
                                      label: occupation.name,
                                      isSelected: controller.selectedOccupationId.value == occupation.id,
                                      onTap: () => controller.selectOccupation(occupation.id, occupation.name),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const Divider(height: 1),
                      
                      // 按钮栏
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: controller.resetFilters,
                              child: const Text('重置'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(120, 40),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: controller.applyFilters,
                              child: const Text('确定'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建类别筛选标签
  Widget _buildCategoryChip({
    required String label, 
    required bool isSelected, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // 构建选择标签
  Widget _buildSelectionChip({
    required String label, 
    required bool isSelected, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
} 
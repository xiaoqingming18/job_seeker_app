import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/labor_demand_model.dart';
import '../../../models/occupation_model.dart';
import '../../../models/occupation_category_model.dart';
import '../../../services/api/labor_demand_api_service.dart';
import '../../../services/api/occupation_api_service.dart';

class LaborDemandSearchController extends GetxController {
  // API 服务
  final LaborDemandApiService _laborDemandApiService = LaborDemandApiService();
  final OccupationApiService _occupationApiService = OccupationApiService();
  
  // 搜索关键词
  final searchKeyword = ''.obs;
  final searchController = TextEditingController();
  
  // 数据列表
  final laborDemands = <LaborDemandModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  
  // 筛选相关状态
  final selectedProjectType = RxString('all');
  final Map<String, String> projectTypeMappings = {
    'all': '全部',
    'residence': '住宅项目',
    'commerce': '商业建筑',
    'industry': '工业项目',
    'municipal': '市政工程',
  };
  
  // 工种筛选状态
  final selectedOccupationId = RxnInt(null);
  final selectedOccupationName = RxString('');
  
  // 工种类别筛选状态
  final selectedCategoryId = RxnInt(null);
  final selectedCategoryName = RxString('');
  
  // 地点筛选状态
  final selectedLocation = RxString('');
  
  // 工种和工种类别数据
  final occupationCategories = <OccupationCategoryModel>[].obs;
  final occupations = <OccupationModel>[].obs;
  final isLoadingOccupations = false.obs;
  
  // 筛选面板控制
  final isFilterPanelOpen = false.obs;
  final focusNode = FocusNode();
  
  @override
  void onInit() {
    super.onInit();
    
    // 获取筛选参数
    final Map<String, dynamic> params = Get.parameters;
    if (params.isNotEmpty) {
      // 处理预设的筛选条件
      if (params.containsKey('projectType')) {
        selectedProjectType.value = params['projectType']!;
      }
      if (params.containsKey('occupationId')) {
        selectedOccupationId.value = int.tryParse(params['occupationId']!);
      }
      if (params.containsKey('occupationName')) {
        selectedOccupationName.value = params['occupationName']!;
      }
      if (params.containsKey('keyword')) {
        searchKeyword.value = params['keyword']!;
        searchController.text = params['keyword']!;
      }
    }
    
    // 获取劳务需求列表
    fetchLaborDemands();
    
    // 获取工种类别和工种数据（供筛选使用）
    fetchOccupationCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    focusNode.dispose();
    super.onClose();
  }
  
  /// 获取工种类别列表
  Future<void> fetchOccupationCategories() async {
    try {
      isLoadingOccupations.value = true;
      
      // 获取工种类别
      final categoriesResponse = await _occupationApiService.getOccupationCategories();
      if (categoriesResponse.isSuccess && categoriesResponse.data != null) {
        occupationCategories.value = categoriesResponse.data!;
        
        // 获取所有工种
        final occupationsResponse = await _occupationApiService.getAllOccupations();
        if (occupationsResponse.isSuccess && occupationsResponse.data != null) {
          occupations.value = occupationsResponse.data!;
        }
      }
    } catch (e) {
      print('获取工种和类别数据失败: $e');
    } finally {
      isLoadingOccupations.value = false;
    }
  }
  
  /// 获取劳务需求列表
  Future<void> fetchLaborDemands({int page = 1, int size = 10}) async {
    try {
      // 设置加载状态
      isLoading.value = true;
      hasError.value = false;
      
      // 构建查询条件
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
        'status': 'open',
      };
      
      // 添加搜索关键词
      if (searchKeyword.isNotEmpty) {
        queryParams['keyword'] = searchKeyword.value;
      }
      
      // 添加项目类型
      if (selectedProjectType.value != 'all') {
        queryParams['projectType'] = selectedProjectType.value;
      }
      
      // 添加工种ID
      if (selectedOccupationId.value != null) {
        queryParams['occupationId'] = selectedOccupationId.value;
      }
      
      // 添加工种类别ID
      if (selectedCategoryId.value != null) {
        queryParams['categoryId'] = selectedCategoryId.value;
      }
      
      // 添加地点
      if (selectedLocation.isNotEmpty) {
        queryParams['location'] = selectedLocation.value;
      }
      
      // 发送请求获取劳务需求列表
      final response = await _laborDemandApiService.filterLaborDemands(
        page: page,
        size: size,
        projectType: selectedProjectType.value == 'all' ? null : selectedProjectType.value,
        occupationId: selectedOccupationId.value,
        categoryId: selectedCategoryId.value,
      );
      
      // 处理响应结果
      if (response.isSuccess && response.data != null) {
        final pageData = response.data!;
        
        // 更新数据
        if (page == 1) {
          // 如果是第一页，则替换所有数据
          laborDemands.value = pageData.records;
        } else {
          // 如果是加载更多，则追加数据
          laborDemands.addAll(pageData.records);
        }
        
        currentPage.value = pageData.current;
        totalPages.value = pageData.pages;
        totalItems.value = pageData.total;
      } else {
        // 设置错误状态
        hasError.value = true;
        errorMessage.value = response.message;
      }
    } catch (e) {
      // 设置错误状态
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      // 结束加载状态
      isLoading.value = false;
    }
  }
  
  /// 刷新劳务需求列表
  Future<void> refreshLaborDemands() async {
    await fetchLaborDemands(page: 1);
  }
  
  /// 加载更多劳务需求
  Future<void> loadMoreLaborDemands() async {
    // 如果当前页小于总页数，则加载下一页
    if (currentPage.value < totalPages.value) {
      await fetchLaborDemands(page: currentPage.value + 1);
    }
  }
  
  /// 切换筛选面板状态
  void toggleFilterPanel() {
    isFilterPanelOpen.value = !isFilterPanelOpen.value;
  }
  
  /// 应用搜索关键词
  void applySearch() {
    searchKeyword.value = searchController.text.trim();
    refreshLaborDemands();
    // 关闭键盘
    focusNode.unfocus();
  }
  
  /// 应用筛选条件
  void applyFilters() {
    refreshLaborDemands();
    isFilterPanelOpen.value = false;
  }
  
  /// 重置筛选条件
  void resetFilters() {
    selectedProjectType.value = 'all';
    selectedOccupationId.value = null;
    selectedOccupationName.value = '';
    selectedCategoryId.value = null;
    selectedCategoryName.value = '';
    selectedLocation.value = '';
    
    refreshLaborDemands();
    isFilterPanelOpen.value = false;
  }
  
  /// 选择项目类型
  void selectProjectType(String projectType) {
    selectedProjectType.value = projectType;
  }
  
  /// 选择工种类别
  void selectCategory(int? categoryId, String categoryName) {
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;
    
    // 如果选择了类别，清除工种筛选
    if (categoryId != null) {
      selectedOccupationId.value = null;
      selectedOccupationName.value = '';
    }
  }
  
  /// 选择工种
  void selectOccupation(int? occupationId, String occupationName) {
    selectedOccupationId.value = occupationId;
    selectedOccupationName.value = occupationName;
    
    // 如果选择了工种，自动选择对应的类别
    if (occupationId != null) {
      final occupation = occupations.firstWhereOrNull((o) => o.id == occupationId);
      if (occupation != null) {
        final category = occupationCategories.firstWhereOrNull((c) => c.id == occupation.categoryId);
        if (category != null) {
          selectedCategoryId.value = category.id;
          selectedCategoryName.value = category.name;
        }
      }
    }
  }
  
  /// 选择地点
  void selectLocation(String location) {
    selectedLocation.value = location;
  }
  
  /// 获取当前选中工种类别下的工种列表
  List<OccupationModel> getOccupationsForSelectedCategory() {
    if (selectedCategoryId.value == null) {
      return occupations;
    }
    return occupations.where((o) => o.categoryId == selectedCategoryId.value).toList();
  }
} 
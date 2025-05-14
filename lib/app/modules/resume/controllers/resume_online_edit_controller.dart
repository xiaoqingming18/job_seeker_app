import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/resume_model.dart';
import '../../../services/api/resume_api_service.dart';
import '../../../services/api/file_api_service.dart';
import '../../../routes/app_pages.dart';

class ResumeOnlineEditController extends GetxController {
  final ResumeApiService _resumeApiService = ResumeApiService();
  final FileApiService _fileApiService = FileApiService();
  
  // 页面状态
  final isLoading = true.obs;
  final isSaving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  // 表单 key
  final formKey = GlobalKey<FormState>();
  
  // 简历 ID，如果是编辑模式则不为空
  final resumeId = Rx<int?>(null);
  
  // 编辑模式状态
  final isEditMode = false.obs;
  
  // 简历基本信息
  final titleController = TextEditingController();
  final status = 'published'.obs;
  final isDefault = true.obs;
  
  // 个人信息
  final realNameController = TextEditingController();
  final gender = Rx<String?>('male');
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final avatarUrl = Rx<String?>(null);
  
  // 教育背景
  final highestEducation = Rx<String?>('bachelor');
  final schoolNameController = TextEditingController();
  final majorController = TextEditingController();
  final educationStartDateController = TextEditingController();
  final educationEndDateController = TextEditingController();
  
  // 工作经历
  final workYearsController = TextEditingController();
  final workExperiences = <WorkExperienceDTO>[].obs;
  
  // 个人能力
  final selfDescriptionController = TextEditingController();
  final skills = <ResumeSkillDTO>[].obs;
  
  // 求职意向
  final jobIntentionController = TextEditingController();
  final expectedSalaryController = TextEditingController();
  final expectedCityController = TextEditingController();
  
  // 教育程度选项
  final educationOptions = [
    {'value': 'primary', 'label': '小学'},
    {'value': 'junior', 'label': '初中'},
    {'value': 'high', 'label': '高中'},
    {'value': 'technical', 'label': '中专'},
    {'value': 'college', 'label': '大专'},
    {'value': 'bachelor', 'label': '本科'},
    {'value': 'master', 'label': '硕士'},
    {'value': 'doctor', 'label': '博士'},
  ];
  
  // 性别选项
  final genderOptions = [
    {'value': 'male', 'label': '男'},
    {'value': 'female', 'label': '女'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    
    // 检查是否为编辑模式
    if (Get.arguments != null && Get.arguments['resumeId'] != null) {
      resumeId.value = Get.arguments['resumeId'];
      isEditMode.value = true;
      fetchResumeDetails();
    } else {
      // 创建模式，初始化默认值
      setupDefaultValues();
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    // 释放控制器资源
    titleController.dispose();
    realNameController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    emailController.dispose();
    schoolNameController.dispose();
    majorController.dispose();
    educationStartDateController.dispose();
    educationEndDateController.dispose();
    workYearsController.dispose();
    selfDescriptionController.dispose();
    jobIntentionController.dispose();
    expectedSalaryController.dispose();
    expectedCityController.dispose();
    super.onClose();
  }
  
  // 设置默认值
  void setupDefaultValues() {
    titleController.text = '我的在线简历';
    status.value = 'published';
    isDefault.value = true;
    gender.value = 'male';
    workYearsController.text = '0';
  }
  
  // 获取简历详情
  Future<void> fetchResumeDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      if (resumeId.value == null) {
        throw Exception('简历ID不能为空');
      }
      
      final response = await _resumeApiService.getOnlineResumeDetail(resumeId.value!);
      
      if (response.isSuccess && response.data != null) {
        final resume = response.data!;
        
        // 填充基本信息
        if (resume.resumeInfo != null) {
          titleController.text = resume.resumeInfo!.title ?? '我的在线简历';
          status.value = resume.resumeInfo!.status ?? 'published';
          isDefault.value = resume.resumeInfo!.isDefault ?? false;
        }
        
        // 填充个人信息
        realNameController.text = resume.realName ?? '';
        gender.value = resume.gender ?? 'male';
        birthDateController.text = resume.birthDate ?? '';
        phoneController.text = resume.phone ?? '';
        emailController.text = resume.email ?? '';
        avatarUrl.value = resume.avatar;
        
        // 填充教育背景
        highestEducation.value = resume.highestEducation ?? 'bachelor';
        if (resume.educationExperiences != null && resume.educationExperiences!.isNotEmpty) {
          final education = resume.educationExperiences!.first;
          schoolNameController.text = education.schoolName ?? '';
          majorController.text = education.major ?? '';
          educationStartDateController.text = education.startDate ?? '';
          educationEndDateController.text = education.endDate ?? '';
        }
        
        // 填充工作经历
        workYearsController.text = (resume.workYears ?? 0).toString();
        if (resume.workExperiences != null) {
          workExperiences.value = resume.workExperiences!;
        }
        
        // 填充个人能力
        selfDescriptionController.text = resume.selfDescription ?? '';
        if (resume.skills != null) {
          skills.value = resume.skills!;
        }
        
        // 填充求职意向
        jobIntentionController.text = resume.jobIntention ?? '';
        expectedSalaryController.text = resume.expectedSalary?.toString() ?? '';
        expectedCityController.text = resume.expectedCity ?? '';
        
        print('获取简历详情成功');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        print('获取简历详情失败: ${response.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('获取简历详情时发生错误: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // 保存简历
  Future<void> saveResume() async {
    try {
      // 表单验证
      if (formKey.currentState?.validate() != true) {
        return;
      }
      
      isSaving.value = true;
      
      // 构建简历数据
      final Map<String, dynamic> resumeData = {
        'resumeInfo': {
          'title': titleController.text,
          'status': status.value,
          'isDefault': isDefault.value,
          'type': 'online',
        },
        'realName': realNameController.text,
        'gender': gender.value,
        'birthDate': birthDateController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'avatar': avatarUrl.value,
        'highestEducation': highestEducation.value,
        'workYears': int.tryParse(workYearsController.text) ?? 0,
        'selfDescription': selfDescriptionController.text,
        'jobIntention': jobIntentionController.text,
        'expectedSalary': double.tryParse(expectedSalaryController.text),
        'expectedCity': expectedCityController.text,
      };
      
      // 添加教育经历
      final educationExperience = {
        'schoolName': schoolNameController.text,
        'major': majorController.text,
        'degree': highestEducation.value,
        'startDate': educationStartDateController.text,
        'endDate': educationEndDateController.text,
      };
      
      // 如果有教育经历，添加到数据中
      if (educationExperience['schoolName'] != null && 
          educationExperience['schoolName'].toString().isNotEmpty) {
        resumeData['educationExperiences'] = [educationExperience];
      }
      
      // 添加工作经历
      if (workExperiences.isNotEmpty) {
        resumeData['workExperiences'] = workExperiences.map((e) => e.toJson()).toList();
      }
      
      // 添加技能
      if (skills.isNotEmpty) {
        resumeData['skills'] = skills.map((e) => e.toJson()).toList();
      }
      
      // 发送请求
      if (isEditMode.value && resumeId.value != null) {
        // 更新模式
        resumeData['resumeInfo']['id'] = resumeId.value;
        
        final response = await _resumeApiService.updateOnlineResume(resumeData);
        
        if (response.isSuccess) {
          Get.snackbar('成功', '简历已更新', snackPosition: SnackPosition.BOTTOM);
          Get.offNamed(Routes.RESUME_ONLINE_VIEW, arguments: {'resumeId': resumeId.value});
        } else {
          Get.snackbar('失败', '更新简历失败: ${response.message}', snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        // 创建模式
        final response = await _resumeApiService.createOnlineResume(resumeData);
        
        if (response.isSuccess && response.data != null) {
          final newResumeId = response.data;
          Get.snackbar('成功', '简历已创建', snackPosition: SnackPosition.BOTTOM);
          Get.offNamed(Routes.RESUME_LIST);
        } else {
          Get.snackbar('失败', '创建简历失败: ${response.message}', snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      Get.snackbar('错误', '保存简历失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
  
  // 选择出生日期
  Future<void> selectBirthDate(BuildContext context) async {
    final initialDate = birthDateController.text.isNotEmpty
        ? DateTime.tryParse(birthDateController.text) ?? DateTime.now().subtract(const Duration(days: 365 * 20))
        : DateTime.now().subtract(const Duration(days: 365 * 20));
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (selectedDate != null) {
      birthDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }
  
  // 选择教育开始日期
  Future<void> selectEducationStartDate(BuildContext context) async {
    final initialDate = educationStartDateController.text.isNotEmpty
        ? DateTime.tryParse(educationStartDateController.text) ?? DateTime.now().subtract(const Duration(days: 365 * 4))
        : DateTime.now().subtract(const Duration(days: 365 * 4));
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    
    if (selectedDate != null) {
      educationStartDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }
  
  // 选择教育结束日期
  Future<void> selectEducationEndDate(BuildContext context) async {
    final initialDate = educationEndDateController.text.isNotEmpty
        ? DateTime.tryParse(educationEndDateController.text) ?? DateTime.now()
        : DateTime.now();
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (selectedDate != null) {
      educationEndDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }
  
  // 添加工作经历
  void addWorkExperience() {
    Get.dialog(
      AlertDialog(
        title: const Text('添加工作经历'),
        content: const Text('工作经历编辑功能即将上线，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 添加专业技能
  void addSkill() {
    Get.dialog(
      AlertDialog(
        title: const Text('添加专业技能'),
        content: const Text('专业技能编辑功能即将上线，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 上传头像
  Future<void> uploadAvatar() async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('上传头像'),
          content: const Text('头像上传功能即将上线，敬请期待！'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('错误', '上传头像失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
} 
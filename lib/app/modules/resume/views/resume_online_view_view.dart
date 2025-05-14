import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resume_online_view_controller.dart';

class ResumeOnlineViewView extends GetView<ResumeOnlineViewController> {
  const ResumeOnlineViewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('简历详情'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: controller.editResume,
          ),
        ],
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
                  '加载简历失败: ${controller.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.onRefresh,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        
        // 简历内容
        final resume = controller.resume.value;
        if (resume == null) {
          return const Center(
            child: Text('未找到简历信息'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: Stack(
            children: [
              // 简历主体内容
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 简历标题和状态
                  if (resume.resumeInfo != null)
                    _buildHeaderSection(resume),
                  
                  // 个人信息
                  _buildPersonalInfoSection(resume),
                  
                  // 教育信息
                  _buildEducationSection(resume),
                  
                  // 工作经历
                  _buildWorkExperienceSection(resume),
                  
                  // 专业技能
                  _buildSkillsSection(resume),
                  
                  // 求职意向
                  _buildJobIntentionSection(resume),
                  
                  // 底部间距
                  const SizedBox(height: 80),
                ],
              ),
              
              // 底部按钮
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: resume.resumeInfo?.isDefault == true
                              ? null
                              : controller.setAsDefault,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            resume.resumeInfo?.isDefault == true ? '默认简历' : '设为默认',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: resume.resumeInfo?.isDefault == true
                                  ? Colors.grey.shade600
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  // 简历标题和状态
  Widget _buildHeaderSection(dynamic resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    resume.resumeInfo?.title ?? '未命名简历',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (resume.resumeInfo?.isDefault == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Text(
                      '默认',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.update, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '更新于 ${resume.updateTime ?? '未知'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 个人信息
  Widget _buildPersonalInfoSection(dynamic resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('基本信息', Icons.person),
            const SizedBox(height: 16),
            
            // 头像和基本信息
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    image: resume.avatar != null && resume.avatar.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(resume.avatar),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: resume.avatar == null || resume.avatar.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                
                // 基本信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.realName ?? '未填写姓名',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(
                            resume.gender == 'male' ? '男' : '女',
                            Icons.wc,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            '${resume.workYears ?? 0}年经验',
                            Icons.work,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildContactInfo(
                        '电话: ${resume.phone ?? '未填写'}',
                        Icons.phone,
                      ),
                      if (resume.email != null && resume.email.isNotEmpty)
                        _buildContactInfo(
                          '邮箱: ${resume.email}',
                          Icons.email,
                        ),
                      if (resume.birthDate != null && resume.birthDate.isNotEmpty)
                        _buildContactInfo(
                          '生日: ${resume.birthDate}',
                          Icons.cake,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (resume.selfDescription != null && resume.selfDescription.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '自我描述',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resume.selfDescription,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // 教育信息
  Widget _buildEducationSection(dynamic resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('教育背景', Icons.school),
            const SizedBox(height: 16),
            
            // 最高学历
            Row(
              children: [
                const Icon(Icons.grade, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  '最高学历:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.getEducationText(resume.highestEducation),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 教育经历列表
            if (resume.educationExperiences == null || resume.educationExperiences.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '未填写教育经历',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: resume.educationExperiences.length,
                itemBuilder: (context, index) {
                  final education = resume.educationExperiences[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                education.schoolName ?? '未知学校',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              controller.getEducationText(education.degree),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          education.major ?? '未知专业',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${education.startDate ?? '未知'} ~ ${education.endDate ?? '未知'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  // 工作经历
  Widget _buildWorkExperienceSection(dynamic resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('工作经历', Icons.work),
            const SizedBox(height: 16),
            
            // 工作经历列表
            if (resume.workExperiences == null || resume.workExperiences.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '未填写工作经历',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: resume.workExperiences.length,
                itemBuilder: (context, index) {
                  final work = resume.workExperiences[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                work.companyName ?? '未知公司',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                work.position ?? '未知职位',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${work.startDate ?? '未知'} ~ ${work.endDate ?? '未知'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (work.description != null && work.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            '工作描述:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            work.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  // 专业技能
  Widget _buildSkillsSection(dynamic resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('专业技能', Icons.psychology),
            const SizedBox(height: 16),
            
            // 技能列表
            if (resume.skills == null || resume.skills.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '未填写专业技能',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: resume.skills.map<Widget>((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getProficiencyColor(skill.proficiency),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skill.occupationName ?? '未知技能',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${controller.getProficiencyText(skill.proficiency)})',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
  
  // 求职意向
  Widget _buildJobIntentionSection(dynamic resume) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('求职意向', Icons.trending_up),
            const SizedBox(height: 16),
            
            if (resume.jobIntention != null && resume.jobIntention.isNotEmpty)
              _buildInfoItem('期望职位', resume.jobIntention, Icons.work),
              
            if (resume.expectedSalary != null)
              _buildInfoItem('期望薪资', '${resume.expectedSalary}元/月', Icons.monetization_on),
              
            if (resume.expectedCity != null && resume.expectedCity.isNotEmpty)
              _buildInfoItem('期望城市', resume.expectedCity, Icons.location_city),
              
            if ((resume.jobIntention == null || resume.jobIntention.isEmpty) &&
                resume.expectedSalary == null &&
                (resume.expectedCity == null || resume.expectedCity.isEmpty))
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '未填写求职意向',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // 构建小节标题
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
  
  // 构建信息芯片
  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建联系信息
  Widget _buildContactInfo(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建信息项
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 根据熟练度获取颜色
  Color _getProficiencyColor(String? proficiency) {
    switch (proficiency) {
      case 'beginner':
        return Colors.green[100]!;
      case 'intermediate':
        return Colors.blue[100]!;
      case 'advanced':
        return Colors.orange[100]!;
      case 'expert':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
} 
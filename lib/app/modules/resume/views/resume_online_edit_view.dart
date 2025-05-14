import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resume_online_edit_controller.dart';

class ResumeOnlineEditView extends GetView<ResumeOnlineEditController> {
  const ResumeOnlineEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value ? '编辑简历' : '创建在线简历')),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          Obx(() {
            if (controller.isSaving.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              );
            } else {
              return TextButton(
                onPressed: controller.saveResume,
                child: const Text(
                  '保存',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          }),
        ],
      ),
      body: Obx(() {
        // 加载状态
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 错误状态
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
                  onPressed: () => Get.back(),
                  child: const Text('返回'),
                ),
              ],
            ),
          );
        }

        // 编辑表单
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 基本信息卡片
              _buildSection(
                title: '基本信息',
                icon: Icons.description,
                children: [
                  TextFormField(
                    controller: controller.titleController,
                    decoration: const InputDecoration(
                      labelText: '简历标题',
                      hintText: '如：前端工程师简历、Java开发简历等',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入简历标题';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.push_pin, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text('设为默认简历'),
                      const Spacer(),
                      Switch(
                        value: controller.isDefault.value,
                        onChanged: (value) => controller.isDefault.value = value,
                      ),
                    ],
                  ),
                ],
              ),

              // 个人信息卡片
              _buildSection(
                title: '个人信息',
                icon: Icons.person,
                children: [
                  // 头像上传
                  GestureDetector(
                    onTap: controller.uploadAvatar,
                    child: Center(
                      child: Obx(() {
                        if (controller.avatarUrl.value != null &&
                            controller.avatarUrl.value!.isNotEmpty) {
                          return CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                NetworkImage(controller.avatarUrl.value!),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '上传头像',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.realNameController,
                    decoration: const InputDecoration(
                      labelText: '姓名',
                      hintText: '您的真实姓名',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入您的姓名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.wc, color: Colors.grey),
                      const SizedBox(width: 16),
                      const Text('性别:'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          children: controller.genderOptions
                              .map(
                                (option) => Obx(
                                  () => ChoiceChip(
                                    label: Text(option['label'] as String),
                                    selected: controller.gender.value ==
                                        option['value'],
                                    onSelected: (selected) {
                                      if (selected) {
                                        controller.gender.value =
                                            option['value'] as String;
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.birthDateController,
                    readOnly: true,
                    onTap: () => controller.selectBirthDate(context),
                    decoration: const InputDecoration(
                      labelText: '出生日期',
                      hintText: '选择您的出生日期',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: '手机号码',
                      hintText: '您的联系电话',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入您的手机号码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '电子邮箱',
                      hintText: '您的电子邮箱地址',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !GetUtils.isEmail(value)) {
                        return '请输入有效的电子邮箱地址';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              // 教育背景卡片
              _buildSection(
                title: '教育背景',
                icon: Icons.school,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grade, color: Colors.grey),
                      const SizedBox(width: 16),
                      const Text('最高学历:'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: controller.highestEducation.value,
                            items: controller.educationOptions
                                .map(
                                  (option) => DropdownMenuItem<String>(
                                    value: option['value'] as String,
                                    child: Text(option['label'] as String),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.highestEducation.value = value;
                              }
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.schoolNameController,
                    decoration: const InputDecoration(
                      labelText: '学校名称',
                      hintText: '您就读的学校',
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.majorController,
                    decoration: const InputDecoration(
                      labelText: '专业',
                      hintText: '您所学的专业',
                      prefixIcon: Icon(Icons.subject),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.educationStartDateController,
                          readOnly: true,
                          onTap: () =>
                              controller.selectEducationStartDate(context),
                          decoration: const InputDecoration(
                            labelText: '入学时间',
                            hintText: '选择入学时间',
                            prefixIcon: Icon(Icons.event),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: controller.educationEndDateController,
                          readOnly: true,
                          onTap: () =>
                              controller.selectEducationEndDate(context),
                          decoration: const InputDecoration(
                            labelText: '毕业时间',
                            hintText: '选择毕业时间',
                            prefixIcon: Icon(Icons.event),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 工作经历卡片
              _buildSection(
                title: '工作经历',
                icon: Icons.work,
                children: [
                  TextFormField(
                    controller: controller.workYearsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '工作年限',
                      hintText: '您的工作年限',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入工作年限';
                      }
                      if (int.tryParse(value) == null) {
                        return '请输入有效的数字';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.workExperiences.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            '暂无工作经历',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.workExperiences.length,
                        itemBuilder: (context, index) {
                          final work = controller.workExperiences[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                '${work.companyName} - ${work.position}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${work.startDate} ~ ${work.endDate}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.addWorkExperience,
                    icon: const Icon(Icons.add),
                    label: const Text('添加工作经历'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),

              // 个人能力卡片
              _buildSection(
                title: '个人能力',
                icon: Icons.psychology,
                children: [
                  TextFormField(
                    controller: controller.selfDescriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '自我描述',
                      hintText: '简要描述您的技能、特长和个性特点',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        '专业技能',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.skills.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            '暂无专业技能',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    } else {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.skills
                            .map(
                              (skill) => Chip(
                                label: Text(skill.occupationName ?? '未知技能'),
                                backgroundColor: _getProficiencyColor(
                                    skill.proficiency ?? 'beginner'),
                              ),
                            )
                            .toList(),
                      );
                    }
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.addSkill,
                    icon: const Icon(Icons.add),
                    label: const Text('添加专业技能'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),

              // 求职意向卡片
              _buildSection(
                title: '求职意向',
                icon: Icons.trending_up,
                children: [
                  TextFormField(
                    controller: controller.jobIntentionController,
                    decoration: const InputDecoration(
                      labelText: '期望职位',
                      hintText: '您期望的职位',
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.expectedSalaryController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '期望薪资 (元/月)',
                      hintText: '您期望的月薪',
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.expectedCityController,
                    decoration: const InputDecoration(
                      labelText: '期望城市',
                      hintText: '您期望工作的城市',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ],
              ),

              // 底部提交按钮
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: controller.saveResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Obx(() {
                  return controller.isSaving.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '保存简历',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                }),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // 构建表单小节
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // 根据熟练度获取颜色
  Color _getProficiencyColor(String proficiency) {
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
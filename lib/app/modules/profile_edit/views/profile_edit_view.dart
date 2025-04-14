import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/profile_edit_controller.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Form(
          key: controller.formKey,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFF5F5F5)],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像部分
                  Center(
                    child: Stack(
                      children: [
                        // 头像显示
                        Obx(() => CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: controller.avatarUrl.isNotEmpty
                              ? NetworkImage(controller.avatarUrl.value)
                              : null,
                          child: controller.avatarUrl.isEmpty
                              ? const Icon(Icons.person, size: 50, color: Colors.blue)
                              : null,
                        )),
                        // 更换头像按钮
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Obx(() => controller.isUploadingAvatar.value
                              ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: controller.pickAndUploadAvatar,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 个人基本信息
                  const Text(
                    '基本信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 用户名
                  _buildTextField(
                    controller: controller.usernameController,
                    label: '用户名',
                    hint: '请输入用户名',
                    prefixIcon: Icons.person,
                    readOnly: true, // 用户名通常不允许修改
                  ),
                  const SizedBox(height: 16),

                  // 真实姓名
                  _buildTextField(
                    controller: controller.realNameController,
                    label: '真实姓名',
                    hint: '请输入真实姓名',
                    prefixIcon: Icons.badge,
                  ),
                  const SizedBox(height: 16),

                  // 性别选择
                  _buildGenderSelector(),
                  const SizedBox(height: 16),

                  // 联系信息
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    '联系信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 手机号码
                  _buildTextField(
                    controller: controller.mobileController,
                    label: '手机号码',
                    hint: '请输入手机号码',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // 电子邮箱
                  _buildTextField(
                    controller: controller.emailController,
                    label: '电子邮箱',
                    hint: '请输入电子邮箱',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // 求职信息
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    '求职信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 期望职位
                  _buildTextField(
                    controller: controller.expectPositionController,
                    label: '期望职位',
                    hint: '请输入期望职位',
                    prefixIcon: Icons.work,
                  ),
                  const SizedBox(height: 16),

                  // 工作年限
                  _buildTextField(
                    controller: controller.workYearsController,
                    label: '工作年限',
                    hint: '请输入工作年限',
                    prefixIcon: Icons.timeline,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // 专业技能
                  _buildTextField(
                    controller: controller.skillController,
                    label: '专业技能',
                    hint: '请输入专业技能，以逗号分隔',
                    prefixIcon: Icons.psychology,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // 专业证书
                  _buildTextField(
                    controller: controller.certificatesController,
                    label: '专业证书',
                    hint: '请输入专业证书，以逗号分隔',
                    prefixIcon: Icons.card_membership,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  // 保存按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isSaving.value 
                          ? null 
                          : controller.saveUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '保存',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // 构建文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: (value) {
        // 可以添加验证逻辑
        return null;
      },
    );
  }

  // 构建性别选择器
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Obx(() => Row(
            children: [
              Radio<String>(
                value: 'male',
                groupValue: controller.selectedGender.value,
                onChanged: (value) {
                  controller.selectedGender.value = value;
                },
              ),
              const Text('男'),
              const SizedBox(width: 32),
              Radio<String>(
                value: 'female',
                groupValue: controller.selectedGender.value,
                onChanged: (value) {
                  controller.selectedGender.value = value;
                },
              ),
              const Text('女'),
            ],
          )),
        ),
      ],
    );
  }
}

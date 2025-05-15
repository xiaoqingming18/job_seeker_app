import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/modules/certificate/controllers/certificate_edit_controller.dart';

class CertificateEditView extends GetView<CertificateEditController> {
  const CertificateEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value ? '编辑证书' : '添加证书')),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return _buildForm(context);
      }),
    );
  }

  // 构建表单
  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 证书名称
          _buildTextField(
            controller: controller.nameController,
            label: '证书名称',
            hintText: '请输入证书名称',
            icon: Icons.badge,
            isRequired: true,
          ),
          
          const SizedBox(height: 16),
          
          // 证书类型选择
          _buildCertificateTypeSelector(),
          
          const SizedBox(height: 16),
          
          // 证书编号
          _buildTextField(
            controller: controller.numberController,
            label: '证书编号',
            hintText: '请输入证书编号（可选）',
            icon: Icons.numbers,
          ),
          
          const SizedBox(height: 16),
          
          // 发证机构
          _buildTextField(
            controller: controller.issuingAuthorityController,
            label: '发证机构',
            hintText: '请输入发证机构（可选）',
            icon: Icons.business,
          ),
          
          const SizedBox(height: 16),
          
          // 日期选择
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  label: '发证日期',
                  value: controller.issueDate.value,
                  onSelect: (date) => controller.setIssueDate(date),
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  label: '到期日期',
                  value: controller.expiryDate.value,
                  onSelect: (date) => controller.setExpiryDate(date),
                  isRequired: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 证书图片上传
          _buildImageUpload(context),
          
          const SizedBox(height: 32),
          
          // 提交按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(() {
              // 确定按钮是否禁用
              final bool isDisabled = controller.isSaving.value || 
                  // 如果是添加模式，且证书类型已存在，禁用按钮
                  (!controller.isEditMode.value && 
                   controller.selectedType.value != null && 
                   controller.selectedType.value!.id != null &&
                   controller.isCertificateTypeExists(controller.selectedType.value!.id!));
              
              // 按钮文本
              final String buttonText = isDisabled && !controller.isSaving.value && 
                  controller.selectedType.value != null && 
                  controller.isCertificateTypeExists(controller.selectedType.value!.id!)
                  ? '已存在该类型证书'
                  : '保存证书';
              
              return ElevatedButton(
                onPressed: isDisabled 
                  ? null 
                  : controller.saveCertificate,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: controller.isCertificateTypeExists(
                    controller.selectedType.value?.id ?? -1
                  ) ? Colors.orange.shade200 : null,
                ),
                child: controller.isSaving.value
                  ? const CircularProgressIndicator()
                  : Text(buttonText),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 构建输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  // 构建证书类型选择器
  Widget _buildCertificateTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '证书类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          // 检查是否已存在该类型证书
          bool isTypeExists = controller.selectedType.value != null && 
                             controller.selectedType.value!.id != null &&
                             controller.isCertificateTypeExists(controller.selectedType.value!.id!);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isTypeExists && !controller.isEditMode.value 
                      ? Colors.orange 
                      : Colors.grey
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isTypeExists && !controller.isEditMode.value 
                    ? Colors.orange.withOpacity(0.1) 
                    : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    hint: const Text('请选择证书类型'),
                    value: controller.selectedType.value?.id,
                    isExpanded: true,
                    items: controller.certificateTypes.map((type) {
                      // 检查是否已存在该类型证书
                      bool itemExists = type.id != null &&
                                      controller.isCertificateTypeExists(type.id!);
                      
                      return DropdownMenuItem<int>(
                        value: type.id,
                        child: Row(
                          children: [
                            Expanded(child: Text(type.name)),
                            if (itemExists && !controller.isEditMode.value)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '已有',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final selectedType = controller.certificateTypes.firstWhere(
                          (type) => type.id == value
                        );
                        controller.selectCertificateType(selectedType);
                      }
                    },
                  ),
                ),
              ),
              
              // 如果已存在证书，显示警告
              if (isTypeExists && !controller.isEditMode.value)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '您已添加过此类型的证书，不建议重复添加',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // 构建日期选择器
  Widget _buildDateSelector({
    required String label,
    required DateTime? value,
    required Function(DateTime) onSelect,
    bool isRequired = false,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: Get.context!,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            
            if (picked != null) {
              onSelect(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  value != null 
                      ? dateFormat.format(value) 
                      : '请选择日期',
                  style: TextStyle(
                    color: value != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建图片上传
  Widget _buildImageUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '证书图片',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '(上传证书照片或扫描件)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          // 显示已上传的图片或默认上传区域
          if (controller.certificateImage.value != null) {
            return _buildUploadedImage(controller.certificateImage.value!);
          } else if (controller.imageUrl.value.isNotEmpty) {
            return _buildNetworkImage(controller.imageUrl.value);
          } else {
            return _buildUploadPlaceholder(context);
          }
        }),
      ],
    );
  }

  // 构建上传占位符
  Widget _buildUploadPlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _showImagePickerOptions(context),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              '点击上传证书图片',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建已上传的本地图片
  Widget _buildUploadedImage(dynamic image) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white.withOpacity(0.8),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _showImagePickerOptions(Get.context!),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.edit),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建网络图片
  Widget _buildNetworkImage(String url) {
    // 处理URL，确保是完整URL
    String fullUrl = url;
    if (url.isNotEmpty && !url.startsWith('http://') && !url.startsWith('https://')) {
      // 使用MinIO服务器的地址
      const String minioServerUrl = 'http://192.168.200.60:9000';
      const String minioBucket = 'job-server';
      
      // 修正URL格式
      if (!url.startsWith('/')) {
        fullUrl = '/$url';
      }
      
      // 构建完整URL
      fullUrl = '$minioServerUrl/$minioBucket$fullUrl';
    }
    
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('图片加载错误: $error, URL: $fullUrl');
                return const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white.withOpacity(0.8),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _showImagePickerOptions(Get.context!),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.edit),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 显示图片选择选项
  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '选择图片来源',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Get.back();
                  controller.pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Get.back();
                  controller.takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 
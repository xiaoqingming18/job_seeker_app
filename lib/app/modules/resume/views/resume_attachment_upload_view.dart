import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resume_attachment_upload_controller.dart';

class ResumeAttachmentUploadView extends GetView<ResumeAttachmentUploadController> {
  const ResumeAttachmentUploadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传简历'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明卡片
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            '使用附件简历',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '您可以上传已有的简历文件，支持PDF、Word等格式，文件大小不超过5MB。',
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 基本信息
              const Text(
                '基本信息',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.titleController,
                decoration: const InputDecoration(
                  labelText: '简历标题',
                  hintText: '给您的简历起个名字',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
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
                  Obx(() => Switch(
                        value: controller.isDefault.value,
                        onChanged: (value) {
                          controller.isDefault.value = value;
                        },
                      )),
                ],
              ),
              const Divider(height: 32),
              
              // 文件上传
              const Text(
                '上传简历文件',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.selectedFilePath.value != null) {
                  // 已选择文件状态
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getFileIcon(controller.selectedFileType.value),
                              color: Colors.blue,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.selectedFileName.value ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    controller.formatFileSize(
                                      controller.selectedFileSize.value,
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                controller.selectedFileName.value = null;
                                controller.selectedFileSize.value = null;
                                controller.selectedFileType.value = null;
                                controller.selectedFilePath.value = null;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  // 未选择文件状态
                  return InkWell(
                    onTap: controller.pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_upload,
                            size: 48,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '点击上传文件',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '支持 PDF、Word 等格式, 最大5MB',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 32),
              
              // 上传按钮
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  if (controller.isUploading.value) {
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: controller.uploadProgress.value,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade300,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '上传中 ${(controller.uploadProgress.value * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: controller.cancelUpload,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('取消上传'),
                        ),
                      ],
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: controller.uploadResume,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '上传简历',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 根据文件类型获取图标
  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    
    if (fileType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileType.contains('word') || 
               fileType.contains('document') ||
               fileType.contains('doc')) {
      return Icons.description;
    } else if (fileType.contains('image')) {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }
} 
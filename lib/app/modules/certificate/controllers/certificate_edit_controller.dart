import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/certificate_model.dart';
import 'package:job_seeker_app/app/services/api/certificate_api_service.dart';

/// 证书编辑控制器
class CertificateEditController extends GetxController {
  // API服务
  final CertificateApiService _certificateApiService = Get.find<CertificateApiService>();
  
  // 表单控制器
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final issuingAuthorityController = TextEditingController();
  
  // 证书类型列表
  final RxList<CertificateType> certificateTypes = <CertificateType>[].obs;
  
  // 选中的证书类型
  final Rxn<CertificateType> selectedType = Rxn<CertificateType>();
  
  // 日期
  final Rx<DateTime?> issueDate = Rx<DateTime?>(null);
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);
  
  // 证书图片
  final Rxn<File> certificateImage = Rxn<File>();
  final RxString imageUrl = ''.obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  
  // 是否是编辑模式
  final RxBool isEditMode = false.obs;
  
  // 证书ID
  int? certificateId;
  
  // 日期格式化
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  
  // 图片选择器
  final ImagePicker _imagePicker = ImagePicker();
  
  // 用于存储用户已有的证书类型ID
  final RxList<int> existingCertificateTypeIds = <int>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // 获取路由参数
    if (Get.arguments != null) {
      if (Get.arguments['id'] != null) {
        certificateId = Get.arguments['id'] as int;
        isEditMode.value = true;
        loadCertificateDetail();
      }
    }
    
    // 加载证书类型
    loadCertificateTypes();
    
    // 加载用户已有的证书类型
    // 强制调用并添加延迟，确保在异步加载完成前该函数已经执行
    Future.delayed(const Duration(milliseconds: 100), () {
      loadExistingCertificateTypes();
    });
  }
  
  @override
  void onClose() {
    nameController.dispose();
    numberController.dispose();
    issuingAuthorityController.dispose();
    super.onClose();
  }
  
  /// 加载证书类型列表
  Future<void> loadCertificateTypes() async {
    isLoading.value = true;
    try {
      final response = await _certificateApiService.getCertificateTypes();
      certificateTypes.value = response.records;
      
      // 打印日志，方便调试
      print('获取到${certificateTypes.length}个证书类型');
      if (certificateTypes.isNotEmpty) {
        print('第一个证书类型: ${certificateTypes[0].name}');
      }
    } catch (e) {
      Get.snackbar('错误', '获取证书类型失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 加载证书详情
  Future<void> loadCertificateDetail() async {
    if (certificateId == null) return;
    
    isLoading.value = true;
    try {
      final certificate = await _certificateApiService.getCertificateDetail(certificateId!);
      
      // 填充表单
      nameController.text = certificate.certificateName;
      numberController.text = certificate.certificateNo ?? '';
      issuingAuthorityController.text = certificate.issuingAuthority ?? '';
      issueDate.value = certificate.issueDate;
      expiryDate.value = certificate.expiryDate;
      imageUrl.value = certificate.imageUrl ?? '';
      
      // 设置证书类型
      if (certificate.certificateTypeId != null) {
        // 等待证书类型加载完成
        while (certificateTypes.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        selectedType.value = certificateTypes.firstWhereOrNull(
          (type) => type.id == certificate.certificateTypeId
        );
      }
    } catch (e) {
      Get.snackbar('错误', '获取证书详情失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 选择证书类型
  void selectCertificateType(CertificateType type) {
    // 检查是否重复，并立即显示警告
    if (!isEditMode.value && type.id != null && isCertificateTypeExists(type.id!)) {
      Get.snackbar(
        '警告', 
        '您已添加过"${type.name}"类型的证书，不建议重复添加。如继续添加，可能被审核拒绝。',
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.orange.shade100,
      );
    }
    
    selectedType.value = type;
    // 如果有预设的发证机构，自动填充
    if (type.issuingAuthority != null && type.issuingAuthority!.isNotEmpty) {
      issuingAuthorityController.text = type.issuingAuthority!;
    }
    
    // 如果有有效期，自动计算到期日期
    if (type.validityYears != null && issueDate.value != null) {
      expiryDate.value = DateTime(
        issueDate.value!.year + type.validityYears!,
        issueDate.value!.month,
        issueDate.value!.day,
      );
    }
    
    print('选择了证书类型: ${type.name}, ID: ${type.id}');
    print('是否已存在该类型证书: ${type.id != null ? isCertificateTypeExists(type.id!) : false}');
  }
  
  /// 设置发证日期
  void setIssueDate(DateTime date) {
    issueDate.value = date;
    
    // 如果选择了证书类型且证书类型有有效期，自动计算到期日期
    if (selectedType.value != null && selectedType.value!.validityYears != null) {
      expiryDate.value = DateTime(
        date.year + selectedType.value!.validityYears!,
        date.month,
        date.day,
      );
    }
  }
  
  /// 设置到期日期
  void setExpiryDate(DateTime date) {
    expiryDate.value = date;
  }
  
  /// 从相册选择图片
  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      certificateImage.value = File(pickedFile.path);
    }
  }
  
  /// 拍照
  Future<void> takePhoto() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      certificateImage.value = File(pickedFile.path);
    }
  }
  
  /// 上传证书图片
  Future<String?> uploadImage(int certificateId) async {
    if (certificateImage.value == null) return imageUrl.value;
    
    try {
      final url = await _certificateApiService.uploadCertificateImage(
        certificateImage.value!, 
        certificateId: certificateId
      );
      return url;
    } catch (e) {
      Get.snackbar('错误', '上传证书图片失败: ${e.toString()}');
      return null;
    }
  }
  
  /// 加载用户已有的证书类型ID列表
  Future<void> loadExistingCertificateTypes() async {
    try {
      // 获取所有证书
      final response = await _certificateApiService.getMyCertificates(size: 100);
      
      print('获取到${response.records.length}个证书');
      
      // 打印所有证书信息
      for (var cert in response.records) {
        print('证书ID: ${cert.id}, 名称: ${cert.certificateName}, 类型ID: ${cert.certificateTypeId}');
      }
      
      // 如果在编辑模式，需要排除当前正在编辑的证书
      if (isEditMode.value && certificateId != null) {
        // 当前正在编辑的证书
        final currentCert = response.records.firstWhereOrNull((cert) => cert.id == certificateId);
        print('当前正在编辑的证书: ${currentCert?.certificateName}, 类型ID: ${currentCert?.certificateTypeId}');
        
        // 过滤掉当前编辑的证书
        final otherCerts = response.records.where((cert) => cert.id != certificateId).toList();
        
        // 从其他证书中提取类型ID
        existingCertificateTypeIds.value = otherCerts
          .where((cert) => cert.certificateTypeId != null)
          .map((cert) => cert.certificateTypeId!)
          .toList();
      } else {
        // 提取所有证书的类型ID
        existingCertificateTypeIds.value = response.records
          .where((cert) => cert.certificateTypeId != null)
          .map((cert) => cert.certificateTypeId!)
          .toList();
      }
      
      print('已加载用户现有证书类型ID: $existingCertificateTypeIds');
    } catch (e) {
      print('加载用户现有证书类型失败: $e');
    }
  }
  
  /// 检查证书类型是否已存在
  bool isCertificateTypeExists(int typeId) {
    final exists = existingCertificateTypeIds.contains(typeId);
    print('检查证书类型ID $typeId 是否存在: $exists');
    return exists;
  }
  
  /// 保存证书
  Future<void> saveCertificate() async {
    // 表单验证
    if (nameController.text.isEmpty) {
      Get.snackbar('错误', '请输入证书名称');
      return;
    }
    
    if (selectedType.value == null) {
      Get.snackbar('错误', '请选择证书类型');
      return;
    }
    
    print('保存证书时选择的类型ID: ${selectedType.value!.id}');
    print('当前已存在的证书类型ID列表: $existingCertificateTypeIds');
    
    // 强制重新检查证书类型是否重复
    await loadExistingCertificateTypes();
    
    // 检查证书类型是否重复 (强化检查，添加必要的空值处理)
    if (!isEditMode.value && 
        selectedType.value != null && 
        selectedType.value!.id != null &&
        existingCertificateTypeIds.contains(selectedType.value!.id!)) {
      Get.snackbar(
        '错误', 
        '您已添加过"${selectedType.value!.name}"类型的证书，不能重复添加',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade100,
      );
      return;
    }
    
    if (issueDate.value == null) {
      Get.snackbar('错误', '请选择发证日期');
      return;
    }
    
    if (expiryDate.value == null) {
      Get.snackbar('错误', '请选择到期日期');
      return;
    }
    
    // 如果没有上传证书图片，提示上传
    if (certificateImage.value == null && imageUrl.value.isEmpty) {
      Get.snackbar('错误', '请上传证书图片');
      return;
    }
    
    isSaving.value = true;
    try {
      // 准备证书数据
      final certificate = Certificate(
        id: isEditMode.value ? certificateId : null,
        certificateName: nameController.text,
        certificateNo: numberController.text.isEmpty ? null : numberController.text,
        certificateTypeId: selectedType.value!.id,
        certificateTypeName: selectedType.value!.name,
        issuingAuthority: issuingAuthorityController.text.isEmpty ? null : issuingAuthorityController.text,
        issueDate: issueDate.value,
        expiryDate: expiryDate.value,
        imageUrl: imageUrl.value,
        status: CertificateStatus.pending,
      );
      
      Certificate savedCertificate;
      
      // 保存证书
      if (isEditMode.value && certificateId != null) {
        savedCertificate = await _certificateApiService.updateCertificate(certificateId!, certificate);
        
        // 如果有需要上传的图片，更新后再上传
        if (certificateImage.value != null) {
          final uploadedImageUrl = await uploadImage(savedCertificate.id!);
          if (uploadedImageUrl != null) {
            // 图片上传成功，不需要做额外处理，因为后端会自动更新证书的图片URL
          }
        }
        
        Get.snackbar(
          '成功', 
          '证书更新成功',
          duration: const Duration(seconds: 2),
        );
      } else {
        // 新增证书，先添加证书，获取ID后再上传图片
        savedCertificate = await _certificateApiService.addCertificate(certificate);
        
        // 如果有需要上传的图片，添加后再上传
        if (certificateImage.value != null) {
          final uploadedImageUrl = await uploadImage(savedCertificate.id!);
          if (uploadedImageUrl != null) {
            // 图片上传成功，不需要做额外处理
          }
        }
        
        Get.snackbar(
          '成功', 
          '证书添加成功',
          duration: const Duration(seconds: 2),
        );
      }
      
      // 延迟返回，确保提示消息显示
      await Future.delayed(const Duration(seconds: 1));
      
      // 返回上一页
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('错误', '保存证书失败: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }
} 
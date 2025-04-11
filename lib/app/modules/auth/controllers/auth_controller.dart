import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  // 控制标签页切换
  late TabController tabController;
  
  // 表单控制
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // 当前是否显示密码
  final showPassword = false.obs;
  final showRegisterPassword = false.obs;
  final showConfirmPassword = false.obs;
  
  // 表单验证
  final phoneFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    tabController.dispose();
    super.onClose();
  }
  
  // 切换密码可见性
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }
  
  void toggleRegisterPasswordVisibility() {
    showRegisterPassword.value = !showRegisterPassword.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }
  
  // 登录逻辑
  void login() {
    if (phoneFormKey.currentState!.validate()) {
      // 登录逻辑实现
      debugPrint('登录成功: ${phoneController.text}');
      // 这里可以调用登录API
    }
  }
  
  // 注册逻辑
  void register() {
    if (registerFormKey.currentState!.validate()) {
      // 注册逻辑实现
      debugPrint('注册成功: ${registerPhoneController.text}');
      // 这里可以调用注册API
    }
  }
  
  // 表单验证方法
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号码';
    } else if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入有效的手机号码';
    }
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    } else if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    return null;
  }
  
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请再次输入密码';
    } else if (value != registerPasswordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }
}
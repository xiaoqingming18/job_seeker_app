import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  // 控制标签页切换
  late TabController tabController;
    // 表单控制
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final registerUsernameController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  
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
    usernameController.dispose();
    passwordController.dispose();
    registerUsernameController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
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
      debugPrint('登录成功: ${usernameController.text}');
      // 这里可以调用登录API
    }
  }
  
  // 注册逻辑
  void register() {
    if (registerFormKey.currentState!.validate()) {
      // 注册逻辑实现
      debugPrint('注册成功: ${registerUsernameController.text}, 邮箱: ${emailController.text}');
      // 这里可以调用注册API
    }
  }
    // 表单验证方法
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    } else if (value.length < 3) {
      return '用户名长度不能少于3位';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    } else if (!GetUtils.isEmail(value)) {
      return '请输入有效的邮箱地址';
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
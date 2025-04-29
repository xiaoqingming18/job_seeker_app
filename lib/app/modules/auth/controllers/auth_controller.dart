import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api/user_api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../services/socket_service.dart';

class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  // 网络请求服务
  final UserApiService _userApiService = UserApiService();
  // Socket.IO 服务
  final SocketService _socketService = Get.find<SocketService>();
  
  // 登录状态
  final isLoading = false.obs;
  
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
  Future<void> login() async {
    if (phoneFormKey.currentState!.validate()) {
      try {
        // 设置加载状态
        isLoading.value = true;
        
        // 调用登录API
        final response = await _userApiService.jobseekerLogin(
          username: usernameController.text,
          password: passwordController.text,
        );
        
        // 处理响应
        if (response.isSuccess) {
          // 登录成功，等待短暂延迟确保token已保存
          await Future.delayed(const Duration(milliseconds: 500));
          
          print('登录成功，准备连接 WebSocket...');
          
          // 尝试连接 WebSocket，等待连接结果
          await _socketService.connect();
          
          // 给连接一些时间完成
          await Future.delayed(const Duration(seconds: 2));
          
          // 检查 WebSocket 连接状态
          if (_socketService.isConnected.value) {
            print('WebSocket 连接成功，准备接收实时消息');
            // 可以添加提示或初始化依赖WebSocket的功能
          } else {
            print('WebSocket 连接未建立，将在后台继续尝试连接');
            // 即使WebSocket未连接，也继续前往主页
            // 后台会通过重连机制继续尝试连接
          }
          
          // 跳转到首页
          Get.offAllNamed(Routes.HOME);
        } else {
          // 显示错误消息
          Get.snackbar(
            '登录失败',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        // 处理异常
        print('登录过程中出现异常: $e');
        Get.snackbar(
          '登录异常',
          '网络请求失败，请检查网络连接',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );      
      } finally {
        // 无论成功与否，都结束加载状态
        isLoading.value = false;
      }
    }
  }
  
  // 注册逻辑
  Future<void> register() async {
    if (registerFormKey.currentState!.validate()) {
      try {
        // 设置加载状态
        isLoading.value = true;
        
        // 调用注册API
        final response = await _userApiService.jobseekerRegister(
          username: registerUsernameController.text,
          password: registerPasswordController.text,
          email: emailController.text,
        );
        
        // 处理响应
        if (response.isSuccess) {
          // 注册成功，显示成功信息并自动切换到登录页
          Get.snackbar(
            '注册成功',
            '请使用您的账号密码登录',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          
          // 填充登录表单并切换到登录页
          usernameController.text = registerUsernameController.text;
          passwordController.text = registerPasswordController.text;
          tabController.animateTo(0); // 切换到登录标签页
          
          // 清空注册表单
          registerUsernameController.clear();
          registerPasswordController.clear();
          confirmPasswordController.clear();
          emailController.clear();
        } else {
          // 显示错误消息
          Get.snackbar(
            '注册失败',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        // 处理异常
        Get.snackbar(
          '注册异常',
          '网络请求失败，请检查网络连接',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } finally {
        // 无论成功与否，都结束加载状态
        isLoading.value = false;
      }
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
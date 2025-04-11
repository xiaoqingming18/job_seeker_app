import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 紫色渐变背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7A35FB),
              Color(0xFF6345E0),
              Color(0xFF5753C7),
            ],
          ),
        ),
        // 使整个内容垂直居中
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. 顶部区域 - 欢迎语和SVG图片左右排布
                    _buildHeaderSection(),
                    
                    // 2 & 3. 表单区域（包含标签页切换器）
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Stack(
                        children: [
                          // 1. 首先放置大图片在底层
                          Positioned(
                            right: -60, // 向右偏移更多，使图片更大部分位于右侧
                            top: 20, // 距离顶部的位置
                            child: SvgPicture.asset(
                              'assets/images/login-bg.svg',
                              height: 350, // 显著增大图片尺寸
                              width: 350,
                            ),
                          ),
                          
                          // 2. 表单卡片内容在上层
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 标签页切换器 - 位于表单卡片顶部
                              _buildTabSection(),
                              
                              // 表单内容区域 - 使用SizedBox限制高度
                              SizedBox(
                                // 登录表单高度
                                height: controller.tabController.index == 0 ? 280 : 350,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95), // 增加轻微透明度，可以隐约看到下面的图片
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16.0),
                                      bottomRight: Radius.circular(16.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16.0),
                                      bottomRight: Radius.circular(16.0),
                                    ),
                                    child: TabBarView(
                                      controller: controller.tabController,
                                      children: [
                                        // 登录表单
                                        _buildLoginForm(),
                                        
                                        // 注册表单
                                        _buildRegisterForm(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 为底部留出空间
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 顶部欢迎语和SVG图片左右排布
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 欢迎语 - 占据左侧
          Expanded(
            flex: 3,
            child: const Text(
              "Hello!\n登录开始你的求职",
              style: TextStyle(
                fontSize: 22.0, // 缩小字体
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
          
          // 右侧留出空间，为了平衡布局
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  // 标签页切换区域 - 与表单衔接
  Widget _buildTabSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            color: Colors.white.withOpacity(0.15),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
          ),
          child: TabBar(
            controller: controller.tabController,
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              border: Border(
                bottom: const BorderSide(
                  color: Colors.white,
                  width: 3.0,
                ),
              ),
            ),
            labelColor: Colors.white,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: const [
              Tab(text: "账号登录"),
              Tab(text: "注册账号"),
            ],
            dividerHeight: 0,
            padding: const EdgeInsets.symmetric(vertical: 5.0),
          ),
        ),
      ),
    );
  }

  // 登录表单 - 更加紧凑的布局
  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0), // 进一步减小内边距
      child: Form(
        key: controller.phoneFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 手机号输入框
            TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                hintText: '请输入手机号/账号',
                prefixIcon: Icons.phone_android,
              ),
              validator: controller.validatePhone,
            ),
            
            const SizedBox(height: 12), // 进一步减少间距
            
            // 密码输入框
            Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: !controller.showPassword.value,
              decoration: _inputDecoration(
                hintText: '请输入您的密码',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showPassword.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              validator: controller.validatePassword,
            )),
            
            const SizedBox(height: 20), // 进一步减少间距
            
            // 登录按钮
            SizedBox(
              width: double.infinity,
              height: 44, // 进一步减小按钮高度
              child: ElevatedButton(
                onPressed: controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF7BCA),
                        Color(0xFFDA5DFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 其他登录方式或找回密码
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '忘记密码?',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13, // 减小字体
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '快速登录',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13, // 减小字体
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 注册表单 - 更加紧凑的布局
  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0), // 进一步减小内边距
      child: Form(
        key: controller.registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 手机号输入框
            TextFormField(
              controller: controller.registerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                hintText: '请输入手机号码',
                prefixIcon: Icons.phone_android,
              ),
              validator: controller.validatePhone,
            ),
            
            const SizedBox(height: 12), // 进一步减少间距
            
            // 密码输入框
            Obx(() => TextFormField(
              controller: controller.registerPasswordController,
              obscureText: !controller.showRegisterPassword.value,
              decoration: _inputDecoration(
                hintText: '请设置密码',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showRegisterPassword.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: controller.toggleRegisterPasswordVisibility,
                ),
              ),
              validator: controller.validatePassword,
            )),
            
            const SizedBox(height: 12), // 进一步减少间距
            
            // 确认密码输入框
            Obx(() => TextFormField(
              controller: controller.confirmPasswordController,
              obscureText: !controller.showConfirmPassword.value,
              decoration: _inputDecoration(
                hintText: '请确认密码',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showConfirmPassword.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
              ),
              validator: controller.validateConfirmPassword,
            )),
            
            const SizedBox(height: 20), // 进一步减少间距
            
            // 注册按钮
            SizedBox(
              width: double.infinity,
              height: 44, // 进一步减小按钮高度
              child: ElevatedButton(
                onPressed: controller.register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF7BCA),
                        Color(0xFFDA5DFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '注册',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8), // 进一步减少间距
            
            // 用户协议
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '注册即表示同意',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11, // 减小字体
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '用户协议',
                    style: TextStyle(
                      color: Color(0xFF6345E0),
                      fontSize: 11, // 减小字体
                    ),
                  ),
                ),
                const Text(
                  '和',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11, // 减小字体
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '隐私政策',
                    style: TextStyle(
                      color: Color(0xFF6345E0),
                      fontSize: 11, // 减小字体
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 输入框装饰
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF6345E0)),
      suffixIcon: suffixIcon,
      fillColor: const Color(0xFFF5F6FA), // 浅灰背景适合白色表单卡片
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12), // 进一步减小输入框内边距
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10), // 减小错误提示字体
    );
  }
}
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
      body: Container(        // 更加鲜明生动的渐变背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFA78BFA), // 明亮紫色
              Color(0xFF8B5CF6), // 中等紫色
              Color(0xFFD8B4FE), // 浅紫罗兰
              Color(0xFF7C3AED), // 深紫罗兰
              Color(0xFFC4B5FD), // 淡薰衣草
            ],
            stops: [0.0, 0.3, 0.5, 0.7, 1.0],
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
                    _buildHeaderSection(),                    // 2 & 3. 表单区域（包含标签页切换器）
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75, // 设置宽度为屏幕宽度的一半
                        child: Stack(
                          clipBehavior: Clip.none, // 允许子项溢出Stack的边界
                          children: [// 1. 首先放置大图片在底层
                          Positioned(
                            right: -80, // 向右偏移部分距离，使图片部分溢出
                            top: -60, // 向上偏移部分距离，使图片部分溢出
                            child: SvgPicture.asset(
                              'assets/images/login-bg.svg',
                              height: 280, // 调整图片尺寸，使其更合适
                              width: 280,
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
                                // 登录表单高度 - 减少高度以减少底部留白
                                height: controller.tabController.index == 0 ? 210 : 250,
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
                            ],                          ),
                        ],
                      ),
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
              Tab(
                child: Text(
                  "登录账号",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Tab(
                child: Text(
                  "注册账号",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
            dividerHeight: 0,
            padding: const EdgeInsets.symmetric(vertical: 5.0),
          ),
        ),
      ),
    );
  }

  // 登录表单
  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0), 
      child: Form(
        key: controller.phoneFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [            // 用户名输入框
            TextFormField(
              controller: controller.usernameController,
              decoration: _inputDecoration(
                hintText: '请输入用户名',
                prefixIcon: Icons.person,
              ),
              style: const TextStyle(fontSize: 14),
              validator: controller.validateUsername,
            ),
            // 密码输入框
            Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: !controller.showPassword.value,              decoration: _inputDecoration(
                hintText: '请输入您的密码',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showPassword.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              style: const TextStyle(fontSize: 14),              validator: controller.validatePassword,
            )),
            
            const SizedBox(height: 16), // 减小登录按钮上方间距
              // 登录按钮
            SizedBox(
              width: double.infinity,
              height: 34,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
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
                    gradient: LinearGradient(
                      colors: [
                        controller.isLoading.value ? Colors.grey.shade400 : Color(0xFFFF7BCA),
                        controller.isLoading.value ? Colors.grey.shade500 : Color(0xFFDA5DFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '登录',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              )),
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
                      fontSize: 12, // 减小字体
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
                      fontSize: 12, // 减小字体
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
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
      child: Form(
        key: controller.registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [            // 用户名输入框
            TextFormField(
              controller: controller.registerUsernameController,
              decoration: _inputDecoration(
                hintText: '请输入用户名',
                prefixIcon: Icons.person,
              ),
              style: const TextStyle(fontSize: 14),
              validator: controller.validateUsername,
            ),
            
            const SizedBox(height: 8), // 保持一致的间距
            
            // 邮箱输入框
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                hintText: '请输入邮箱',
                prefixIcon: Icons.email,
              ),
              style: const TextStyle(fontSize: 14),
              validator: controller.validateEmail,
            ),
              // 密码输入框
            Obx(() => TextFormField(
              controller: controller.registerPasswordController,
              obscureText: !controller.showRegisterPassword.value,              decoration: _inputDecoration(
                hintText: '请设置密码',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showRegisterPassword.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onPressed: controller.toggleRegisterPasswordVisibility,
                ),
              ),
              style: const TextStyle(fontSize: 14),
              validator: controller.validatePassword,
            )),
            
            const SizedBox(height: 20), // 进一步减少间距
            
            // 注册按钮
            SizedBox(
              width: double.infinity,
              height: 34, // 进一步减小按钮高度
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ), // 进一步减少间距
            
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
  }) {    return InputDecoration(
      hintText: hintText,      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12), 
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF6345E0), size: 16.0),
      suffixIcon: suffixIcon,
      fillColor: const Color(0xFFF5F6FA), 
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8), // 减小内边距以降低输入框高度
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10), // 减小错误提示字体
    );
  }
}
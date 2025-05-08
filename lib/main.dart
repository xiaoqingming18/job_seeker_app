import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'app/routes/app_pages.dart';
import 'app/services/socket_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/im_service.dart';
import 'app/services/api/user_api_service.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化全局依赖项
  // 添加UserApiService作为全局依赖项
  Get.put(UserApiService());
  
  // 初始化 SocketService
  await Get.putAsync(() => SocketService().init());
  
  // 初始化 NotificationService
  await Get.putAsync(() => NotificationService().init());
  
  // 初始化 ImService
  await Get.putAsync(() => ImService().init());
  
  // 打印SharedPreferences中的token信息
  await printTokenInfo();
  
  runApp(const MainApp());
}

/// 打印token信息和用户资料的辅助函数
Future<void> printTokenInfo() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');
    final profileJson = prefs.getString('jobseeker_profile');
    
    print('==================================================');
    print('TOKEN 和用户信息检查:');
    print('是否存在token: ${token != null}');
    if (token != null) {
      print('Token 值: $token');
      print('Token 长度: ${token.length}');
    } else {
      print('Token 不存在');
    }
    
    print('\n用户ID: $userId');
    
    print('\n用户资料是否存在: ${profileJson != null && profileJson.isNotEmpty}');
    if (profileJson != null && profileJson.isNotEmpty) {
      try {
        final decodedProfile = jsonDecode(profileJson);
        print('用户资料中的ID: ${decodedProfile['userId']}');
        print('用户资料中的用户名: ${decodedProfile['username']}');
      } catch (e) {
        print('解析用户资料时出错: $e');
      }
    }
    print('==================================================');
  } catch (e) {
    print('==================================================');
    print('读取用户信息时出错: $e');
    print('==================================================');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "求职者应用",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

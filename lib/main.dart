import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';
import 'app/services/socket_service.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 SocketService
  await Get.putAsync(() => SocketService().init());
  
  // 打印SharedPreferences中的token信息
  await printTokenInfo();
  
  runApp(const MainApp());
}

/// 打印token信息的辅助函数
Future<void> printTokenInfo() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    print('==================================================');
    print('TOKEN 信息检查:');
    print('是否存在token: ${token != null}');
    if (token != null) {
      print('Token 值: $token');
      print('Token 长度: ${token.length}');
    } else {
      print('Token 不存在');
    }
    print('==================================================');
  } catch (e) {
    print('==================================================');
    print('读取Token时出错: $e');
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

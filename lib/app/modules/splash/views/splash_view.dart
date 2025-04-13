import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用标志
              const Icon(
                Icons.work_outline,
                size: 120,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              // 应用名称
              const Text(
                '求职者应用',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 48),
              // 加载指示器 - 根据状态显示不同的指示器
              if (controller.isLoading.value)
                const CircularProgressIndicator()
              else
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red[300],
                ),
              const SizedBox(height: 16),
              // 状态消息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  controller.message.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.isLoading.value ? Colors.grey : Colors.red,
                    fontWeight: controller.isLoading.value ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
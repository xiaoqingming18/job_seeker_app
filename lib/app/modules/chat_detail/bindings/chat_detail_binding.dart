import 'package:get/get.dart';
import '../controllers/chat_detail_controller.dart';

class ChatDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatDetailController>(
      () => ChatDetailController(
        conversationId: int.parse(Get.parameters['id'] ?? '0'),
        targetUserId: int.parse(Get.parameters['targetUserId'] ?? '0'),
        isGroup: (Get.parameters['isGroup'] ?? 'false').toLowerCase() == 'true',
      ),
    );
  }
} 
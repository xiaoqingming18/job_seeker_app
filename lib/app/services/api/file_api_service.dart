import 'dart:io';
import 'package:dio/dio.dart';
import 'http_client.dart';

/// 文件API服务
/// 提供文件上传相关功能
class FileApiService {
  final HttpClient _httpClient = HttpClient();
  
  /// 上传文件
  /// [file] 要上传的文件
  /// [onProgress] 上传进度回调
  Future<String> uploadFile(
    File file, {
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      // 创建FormData
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });
      
      // 设置进度回调
      Options options = Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      );
      
      // 发送请求
      final response = await _httpClient.post(
        '/file/upload',
        data: formData,
        options: options,
        onSendProgress: (sent, total) {
          // 回调发送进度
          if (onProgress != null) {
            onProgress(sent, total);
          }
          print('文件上传进度: ${(sent / total * 100).toStringAsFixed(2)}%');
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['code'] == 0 && responseData['message'] == 'success') {
          // 返回上传成功后的文件URL
          return responseData['data']['url'];
        } else {
          throw Exception('文件上传失败: ${responseData['message']}');
        }
      } else {
        throw Exception('文件上传请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('网络请求错误: ${e.message}');
    } catch (e) {
      throw Exception('文件上传异常: $e');
    }
  }
  
  /// 上传图片
  Future<String> uploadImage(
    File imageFile, {
    Function(int sent, int total)? onProgress,
  }) async {
    return uploadFile(imageFile, onProgress: onProgress);
  }
  
  /// 上传视频
  Future<String> uploadVideo(
    File videoFile, {
    Function(int sent, int total)? onProgress,
  }) async {
    return uploadFile(videoFile, onProgress: onProgress);
  }
  
  /// 上传音频
  Future<String> uploadAudio(
    File audioFile, {
    Function(int sent, int total)? onProgress,
  }) async {
    return uploadFile(audioFile, onProgress: onProgress);
  }
} 
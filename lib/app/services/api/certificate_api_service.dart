import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:job_seeker_app/app/models/api_response.dart';
import 'package:job_seeker_app/app/models/certificate_model.dart';
import 'package:job_seeker_app/app/services/api/http_client.dart';

/// 证书API服务类
class CertificateApiService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  /// 获取证书类型列表
  Future<CertificateTypeListResponse> getCertificateTypes({
    String? category,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      
      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }
      
      final response = await _httpClient.get(
        '/api/certificate-types/options',
        queryParameters: params,
      );
      
      final data = ApiResponse.fromJson(
        response.data, 
        (json) {
          // 从接口返回的数据中构建CertificateType对象列表
          if (json is List) {
            final types = json.map((item) {
              // 将CertificateTypeOptionVO转换为CertificateType
              return CertificateType(
                id: item['id'] as int?,
                name: item['name'] as String,
                issuingAuthority: item['issuingAuthority'] as String?,
                // 其他字段设为默认值或null
                category: null,
                validityYears: null,
                icon: null,
                description: null,
                status: 1,
              );
            }).toList();
            
            return CertificateTypeListResponse(
              records: types,
              total: types.length,
              size: types.length,
              current: 1
            );
          } else if (json is Map<String, dynamic>) {
            // 如果是分页对象
            return CertificateTypeListResponse.fromJson(json);
          } else {
            // 返回空列表
            return CertificateTypeListResponse(
              records: [],
              total: 0,
              size: 0,
              current: 1
            );
          }
        }
      );
      return data.data!;
    } catch (e) {
      print('获取证书类型列表错误: $e');
      rethrow;
    }
  }

  /// 获取我的证书列表
  Future<CertificateListResponse> getMyCertificates({
    int page = 1,
    int size = 10,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'size': size,
      };
      
      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }
      
      final response = await _httpClient.get(
        '/api/job-seeker/certificates',
        queryParameters: params,
      );
      
      final data = ApiResponse.fromJson(
        response.data,
        (json) => CertificateListResponse.fromJson(json as Map<String, dynamic>)
      );
      return data.data!;
    } catch (e) {
      print('获取证书列表错误: $e');
      // 在出错时返回空列表，避免UI崩溃
      return CertificateListResponse(
        records: [],
        total: 0,
        size: size,
        current: page
      );
    }
  }

  /// 获取证书详情
  Future<Certificate> getCertificateDetail(int certificateId) async {
    try {
      final response = await _httpClient.get(
        '/api/job-seeker/certificates/$certificateId',
      );
      
      final data = ApiResponse.fromJson(
        response.data,
        (json) => Certificate.fromJson(json as Map<String, dynamic>)
      );
      return data.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// 添加证书
  Future<Certificate> addCertificate(Certificate certificate) async {
    try {
      // 将Certificate对象转换为后端需要的JobSeekerCertificateRequest格式
      final Map<String, dynamic> requestData = {
        'certificateTypeId': certificate.certificateTypeId,
        'certificateName': certificate.certificateName,
        'certificateNo': certificate.certificateNo,
        'issuingAuthority': certificate.issuingAuthority,
        // 将DateTime转换为yyyy-MM-dd格式的字符串
        'issueDate': certificate.issueDate != null 
          ? '${certificate.issueDate!.year}-${certificate.issueDate!.month.toString().padLeft(2, '0')}-${certificate.issueDate!.day.toString().padLeft(2, '0')}'
          : null,
        'expiryDate': certificate.expiryDate != null
          ? '${certificate.expiryDate!.year}-${certificate.expiryDate!.month.toString().padLeft(2, '0')}-${certificate.expiryDate!.day.toString().padLeft(2, '0')}'
          : null,
      };
      
      final response = await _httpClient.post(
        '/api/job-seeker/certificates',
        data: requestData,
      );
      
      final data = ApiResponse.fromJson(
        response.data,
        (json) => Certificate.fromJson(json as Map<String, dynamic>)
      );
      return data.data!;
    } catch (e) {
      print('添加证书错误: $e');
      rethrow;
    }
  }

  /// 更新证书
  Future<Certificate> updateCertificate(int certificateId, Certificate certificate) async {
    try {
      // 将Certificate对象转换为后端需要的JobSeekerCertificateRequest格式
      final Map<String, dynamic> requestData = {
        'certificateTypeId': certificate.certificateTypeId,
        'certificateName': certificate.certificateName,
        'certificateNo': certificate.certificateNo,
        'issuingAuthority': certificate.issuingAuthority,
        // 将DateTime转换为yyyy-MM-dd格式的字符串
        'issueDate': certificate.issueDate != null 
          ? '${certificate.issueDate!.year}-${certificate.issueDate!.month.toString().padLeft(2, '0')}-${certificate.issueDate!.day.toString().padLeft(2, '0')}'
          : null,
        'expiryDate': certificate.expiryDate != null
          ? '${certificate.expiryDate!.year}-${certificate.expiryDate!.month.toString().padLeft(2, '0')}-${certificate.expiryDate!.day.toString().padLeft(2, '0')}'
          : null,
      };
      
      final response = await _httpClient.put(
        '/api/job-seeker/certificates/$certificateId',
        data: requestData,
      );
      
      final data = ApiResponse.fromJson(
        response.data,
        (json) => Certificate.fromJson(json as Map<String, dynamic>)
      );
      return data.data!;
    } catch (e) {
      print('更新证书错误: $e');
      rethrow;
    }
  }

  /// 删除证书
  Future<void> deleteCertificate(int certificateId) async {
    try {
      await _httpClient.delete(
        '/api/job-seeker/certificates/$certificateId',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 上传证书图片
  Future<String> uploadCertificateImage(File imageFile, {required int certificateId}) async {
    try {
      // 创建FormData对象
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      
      // 发送请求
      final response = await _httpClient.post(
        '/api/job-seeker/certificates/$certificateId/upload-image',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      // 解析响应
      final data = ApiResponse.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>
      );
      return data.data!['image_url'] as String;
    } catch (e) {
      print('上传证书图片错误: $e');
      rethrow;
    }
  }
} 
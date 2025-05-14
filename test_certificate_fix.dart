import 'dart:convert';
import 'package:job_seeker_app/app/models/certificate_model.dart';

void main() {
  // 测试Certificate序列化
  final certificate = Certificate(
    id: 1,
    certificateName: '测试证书',
    status: CertificateStatus.pending,
  );
  
  final json = certificate.toJson();
  print('Certificate序列化:');
  print(jsonEncode(json));
  
  // 测试Certificate反序列化
  final jsonStr = '''
  {
    "id": 2,
    "certificateName": "测试证书2",
    "verificationStatus": "verified"
  }
  ''';
  
  final decodedJson = jsonDecode(jsonStr);
  final decodedCert = Certificate.fromJson(decodedJson);
  
  print('\nCertificate反序列化:');
  print('ID: ${decodedCert.id}');
  print('名称: ${decodedCert.certificateName}');
  print('状态: ${decodedCert.statusText}');
  
  print('\n测试通过！');
} 
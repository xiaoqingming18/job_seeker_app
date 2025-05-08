import 'package:intl/intl.dart';

class AttendanceModel {
  final int id;
  final int memberId;
  final int projectId;
  final String projectName;
  final DateTime attendanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String statusDesc;
  final double? workHours;
  final String? location;
  final String? remarks;
  final DateTime createTime;

  AttendanceModel({
    required this.id,
    required this.memberId,
    required this.projectId,
    required this.projectName,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.statusDesc,
    this.workHours,
    this.location,
    this.remarks,
    required this.createTime,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    // 解析考勤日期
    DateTime attendanceDate = DateTime.now();
    if (json['attendanceDate'] != null) {
      attendanceDate = dateFormat.parse(json['attendanceDate']);
    }

    // 解析签到时间
    DateTime? checkInTime;
    if (json['checkInTime'] != null) {
      final time = timeFormat.parse(json['checkInTime']);
      checkInTime = DateTime(
        attendanceDate.year,
        attendanceDate.month,
        attendanceDate.day,
        time.hour,
        time.minute,
        time.second,
      );
    }

    // 解析签退时间
    DateTime? checkOutTime;
    if (json['checkOutTime'] != null) {
      final time = timeFormat.parse(json['checkOutTime']);
      checkOutTime = DateTime(
        attendanceDate.year,
        attendanceDate.month,
        attendanceDate.day,
        time.hour,
        time.minute,
        time.second,
      );
    }

    // 解析创建时间
    DateTime createTime = DateTime.now();
    if (json['createTime'] != null) {
      createTime = DateTime.parse(json['createTime']);
    }

    return AttendanceModel(
      id: json['id'],
      memberId: json['memberId'],
      projectId: json['projectId'],
      projectName: json['projectName'] ?? '',
      attendanceDate: attendanceDate,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      status: json['status'] ?? '',
      statusDesc: json['statusDesc'] ?? '',
      workHours: json['workHours'] != null ? double.parse(json['workHours'].toString()) : null,
      location: json['location'],
      remarks: json['remarks'],
      createTime: createTime,
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    return {
      'id': id,
      'memberId': memberId,
      'projectId': projectId,
      'projectName': projectName,
      'attendanceDate': dateFormat.format(attendanceDate),
      'checkInTime': checkInTime != null ? timeFormat.format(checkInTime!) : null,
      'checkOutTime': checkOutTime != null ? timeFormat.format(checkOutTime!) : null,
      'status': status,
      'statusDesc': statusDesc,
      'workHours': workHours,
      'location': location,
      'remarks': remarks,
      'createTime': createTime.toIso8601String(),
    };
  }
} 
// 用于解析列表数据的帮助方法
import 'package:job_seeker_app/app/models/attendance_model.dart';

List<AttendanceModel> attendanceListFromJson(List<dynamic> jsonList) {
  return jsonList.map((item) => AttendanceModel.fromJson(item)).toList();
}

List<Map<String, dynamic>> attendanceListToJson(List<AttendanceModel> attendanceList) {
  return attendanceList.map((item) => item.toJson()).toList();
} 
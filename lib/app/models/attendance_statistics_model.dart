class AttendanceStatisticsModel {
  final int totalDays;
  final int workDays;
  final int attendanceDays;
  final int absenceDays;
  final int leaveDays;
  final int normalDays;
  final int lateDays;
  final int earlyLeaveDays;
  final double totalWorkHours;
  final double averageDailyHours;
  final double attendanceRate;

  AttendanceStatisticsModel({
    required this.totalDays,
    required this.workDays,
    required this.attendanceDays,
    required this.absenceDays,
    required this.leaveDays,
    required this.normalDays,
    required this.lateDays,
    required this.earlyLeaveDays,
    required this.totalWorkHours,
    required this.averageDailyHours,
    required this.attendanceRate,
  });

  factory AttendanceStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatisticsModel(
      totalDays: json['totalDays'] ?? 0,
      workDays: json['workDays'] ?? 0,
      attendanceDays: json['attendanceDays'] ?? 0,
      absenceDays: json['absenceDays'] ?? 0,
      leaveDays: json['leaveDays'] ?? 0,
      normalDays: json['normalDays'] ?? 0,
      lateDays: json['lateDays'] ?? 0,
      earlyLeaveDays: json['earlyLeaveDays'] ?? 0,
      totalWorkHours: json['totalWorkHours'] != null ? double.parse(json['totalWorkHours'].toString()) : 0.0,
      averageDailyHours: json['averageDailyHours'] != null ? double.parse(json['averageDailyHours'].toString()) : 0.0,
      attendanceRate: json['attendanceRate'] != null ? double.parse(json['attendanceRate'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDays': totalDays,
      'workDays': workDays,
      'attendanceDays': attendanceDays,
      'absenceDays': absenceDays,
      'leaveDays': leaveDays,
      'normalDays': normalDays,
      'lateDays': lateDays,
      'earlyLeaveDays': earlyLeaveDays,
      'totalWorkHours': totalWorkHours,
      'averageDailyHours': averageDailyHours,
      'attendanceRate': attendanceRate,
    };
  }
} 
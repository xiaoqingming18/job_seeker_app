class SalaryModel {
  final int? id;
  final int? projectId;
  final String? projectName;
  final int? projectMemberId;
  final String? userName;
  final String? attendanceCode;
  final int? year;
  final int? month;
  final double? basicSalary;
  final double? overtimePay;
  final double? totalAmount;
  final int? workDays;
  final String? status;
  final String? remark;
  final String? paymentTime;
  final String? createTime;
  final List<SalaryItemModel>? items;

  SalaryModel({
    this.id,
    this.projectId,
    this.projectName,
    this.projectMemberId,
    this.userName,
    this.attendanceCode,
    this.year,
    this.month,
    this.basicSalary,
    this.overtimePay,
    this.totalAmount,
    this.workDays,
    this.status,
    this.remark,
    this.paymentTime,
    this.createTime,
    this.items,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      id: json['id'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      projectMemberId: json['projectMemberId'],
      userName: json['userName'],
      attendanceCode: json['attendanceCode'],
      year: json['year'],
      month: json['month'],
      basicSalary: json['basicSalary']?.toDouble(),
      overtimePay: json['overtimePay']?.toDouble(),
      totalAmount: json['totalAmount']?.toDouble(),
      workDays: json['workDays'],
      status: json['status'],
      remark: json['remark'],
      paymentTime: json['paymentTime'],
      createTime: json['createTime'],
      items: json['items'] != null
          ? List<SalaryItemModel>.from(
              json['items'].map((item) => SalaryItemModel.fromJson(item)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'projectMemberId': projectMemberId,
      'userName': userName,
      'attendanceCode': attendanceCode,
      'year': year,
      'month': month,
      'basicSalary': basicSalary,
      'overtimePay': overtimePay,
      'totalAmount': totalAmount,
      'workDays': workDays,
      'status': status,
      'remark': remark,
      'paymentTime': paymentTime,
      'createTime': createTime,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  // 获取工资单状态的显示文本
  String get statusText {
    switch (status) {
      case 'pending':
        return '待确认';
      case 'confirmed':
        return '已确认';
      case 'paid':
        return '已发放';
      default:
        return '未知状态';
    }
  }

  // 获取工资单状态的显示颜色
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA000'; // 警告色（橙色）
      case 'confirmed':
        return '#2196F3'; // 成功色（蓝色）
      case 'paid':
        return '#4CAF50'; // 信息色（绿色）
      default:
        return '#9E9E9E'; // 灰色
    }
  }
}

class SalaryItemModel {
  final int? id;
  final int? salaryId;
  final String? itemType;
  final String? itemName;
  final double? amount;
  final double? quantity;
  final double? unitPrice;
  final String? description;

  SalaryItemModel({
    this.id,
    this.salaryId,
    this.itemType,
    this.itemName,
    this.amount,
    this.quantity,
    this.unitPrice,
    this.description,
  });

  factory SalaryItemModel.fromJson(Map<String, dynamic> json) {
    return SalaryItemModel(
      id: json['id'],
      salaryId: json['salaryId'],
      itemType: json['itemType'],
      itemName: json['itemName'],
      amount: json['amount']?.toDouble(),
      quantity: json['quantity']?.toDouble(),
      unitPrice: json['unitPrice']?.toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salaryId': salaryId,
      'itemType': itemType,
      'itemName': itemName,
      'amount': amount,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'description': description,
    };
  }

  // 获取项目类型的显示文本
  String get itemTypeText {
    switch (itemType) {
      case 'attendance':
        return '出勤工资';
      case 'overtime':
        return '加班费';
      case 'bonus':
        return '奖金';
      case 'subsidy':
        return '补贴';
      case 'deduction':
        return '扣款';
      default:
        return '其他';
    }
  }

  // 获取项目类型的显示颜色
  String get itemTypeColor {
    switch (itemType) {
      case 'attendance':
        return '#2196F3'; // 蓝色
      case 'overtime':
        return '#FF9800'; // 橙色
      case 'bonus':
        return '#4CAF50'; // 绿色
      case 'subsidy':
        return '#9C27B0'; // 紫色
      case 'deduction':
        return '#F44336'; // 红色
      default:
        return '#9E9E9E'; // 灰色
    }
  }
} 
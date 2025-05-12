import 'dart:convert';

/// 绩效评估模型，用于表示项目成员的绩效评估信息
class PerformanceModel {
  final int id;
  final int memberId;
  final String memberName;
  final int projectId;
  final String projectName;
  final String evaluationPeriod;
  final int evaluatorId;
  final String evaluatorName;
  final int workQualityScore;
  final int efficiencyScore;
  final int attitudeScore;
  final int teamworkScore;
  final double totalScore;
  final String? strengths;
  final String? weaknesses;
  final String? comments;
  final String createTime;
  final String? updateTime;
  final String? position;
  final String? occupationName;

  PerformanceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.projectId,
    required this.projectName,
    required this.evaluationPeriod,
    required this.evaluatorId,
    required this.evaluatorName,
    required this.workQualityScore,
    required this.efficiencyScore,
    required this.attitudeScore,
    required this.teamworkScore,
    required this.totalScore,
    this.strengths,
    this.weaknesses,
    this.comments,
    required this.createTime,
    this.updateTime,
    this.position,
    this.occupationName,
  });

  /// 从JSON映射创建绩效评估模型实例
  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      id: json['id'],
      memberId: json['memberId'],
      memberName: json['memberName'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      evaluationPeriod: json['evaluationPeriod'],
      evaluatorId: json['evaluatorId'],
      evaluatorName: json['evaluatorName'],
      workQualityScore: json['workQualityScore'],
      efficiencyScore: json['efficiencyScore'],
      attitudeScore: json['attitudeScore'],
      teamworkScore: json['teamworkScore'],
      totalScore: json['totalScore'] is int 
        ? (json['totalScore'] as int).toDouble() 
        : json['totalScore'],
      strengths: json['strengths'],
      weaknesses: json['weaknesses'],
      comments: json['comments'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      position: json['position'],
      occupationName: json['occupationName'],
    );
  }

  /// 将绩效评估模型实例转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'projectId': projectId,
      'projectName': projectName,
      'evaluationPeriod': evaluationPeriod,
      'evaluatorId': evaluatorId,
      'evaluatorName': evaluatorName,
      'workQualityScore': workQualityScore,
      'efficiencyScore': efficiencyScore,
      'attitudeScore': attitudeScore,
      'teamworkScore': teamworkScore,
      'totalScore': totalScore,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'comments': comments,
      'createTime': createTime,
      'updateTime': updateTime,
      'position': position,
      'occupationName': occupationName,
    };
  }

  @override
  String toString() {
    return 'PerformanceModel(id: $id, memberId: $memberId, memberName: $memberName, '
        'projectId: $projectId, projectName: $projectName, evaluationPeriod: $evaluationPeriod, '
        'evaluatorId: $evaluatorId, evaluatorName: $evaluatorName, '
        'workQualityScore: $workQualityScore, efficiencyScore: $efficiencyScore, '
        'attitudeScore: $attitudeScore, teamworkScore: $teamworkScore, totalScore: $totalScore, '
        'strengths: $strengths, weaknesses: $weaknesses, comments: $comments, '
        'createTime: $createTime, updateTime: $updateTime, '
        'position: $position, occupationName: $occupationName)';
  }
}

/// 分页查询中的绩效评估列表响应
class PerformancePageResult {
  final List<PerformanceModel> list;
  final int total;
  final int pageNum;
  final int pageSize;
  final int totalPages;

  PerformancePageResult({
    required this.list,
    required this.total,
    required this.pageNum,
    required this.pageSize,
    required this.totalPages,
  });

  factory PerformancePageResult.fromJson(Map<String, dynamic> json) {
    return PerformancePageResult(
      list: (json['list'] as List)
          .map((item) => PerformanceModel.fromJson(item))
          .toList(),
      total: json['total'],
      pageNum: json['pageNum'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((item) => item.toJson()).toList(),
      'total': total,
      'pageNum': pageNum,
      'pageSize': pageSize,
      'totalPages': totalPages,
    };
  }
}

/// 绩效评估查询参数
class PerformanceQueryParams {
  final int? projectId;
  final int? memberId;
  final String? evaluationPeriod;
  final int pageNum;
  final int pageSize;

  PerformanceQueryParams({
    this.projectId,
    this.memberId,
    this.evaluationPeriod,
    this.pageNum = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> params = {
      'pageNum': pageNum,
      'pageSize': pageSize,
    };

    if (projectId != null) {
      params['projectId'] = projectId;
    }

    if (memberId != null) {
      params['memberId'] = memberId;
    }

    if (evaluationPeriod != null && evaluationPeriod!.isNotEmpty) {
      params['evaluationPeriod'] = evaluationPeriod;
    }

    return params;
  }
} 
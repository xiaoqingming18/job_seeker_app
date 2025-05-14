part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const HOME = _Paths.HOME;
  static const PROFILE_EDIT = _Paths.PROFILE_EDIT;
  static const SETTINGS = _Paths.SETTINGS;
  static const JOB_DETAIL = _Paths.JOB_DETAIL;
  static const MY_APPLICATIONS = _Paths.MY_APPLICATIONS;
  static const CONTRACT_SIGN = _Paths.CONTRACT_SIGN;
  static const CHAT_DETAIL = _Paths.CHAT_DETAIL;
  static const LABOR_DEMAND_SEARCH = _Paths.LABOR_DEMAND_SEARCH;
  static const NOTIFICATION_TEST = _Paths.NOTIFICATION_TEST;
  static const ATTENDANCE = _Paths.ATTENDANCE;
  static const LEAVE = _Paths.LEAVE;
  static const PERFORMANCE = _Paths.PERFORMANCE;
  static const PERFORMANCE_DETAIL = _Paths.PERFORMANCE_DETAIL;
  static const SALARY = _Paths.SALARY;
  static const SALARY_DETAIL = _Paths.SALARY_DETAIL;
  static const RESUME_LIST = _Paths.RESUME_LIST;
  static const RESUME_ONLINE_EDIT = _Paths.RESUME_ONLINE_EDIT;
  static const RESUME_ONLINE_VIEW = _Paths.RESUME_ONLINE_VIEW;
  static const RESUME_ATTACHMENT_UPLOAD = _Paths.RESUME_ATTACHMENT_UPLOAD;
  static const RESUME_ATTACHMENT_VIEW = _Paths.RESUME_ATTACHMENT_VIEW;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const HOME = '/home';
  static const PROFILE_EDIT = '/profile-edit';
  static const SETTINGS = '/settings';
  static const JOB_DETAIL = '/job-detail';
  static const MY_APPLICATIONS = '/my-applications';
  static const CONTRACT_SIGN = '/contract-sign';
  static const CHAT_DETAIL = '/chat-detail';
  static const LABOR_DEMAND_SEARCH = '/labor-demand-search';
  static const NOTIFICATION_TEST = '/notification-test';
  static const ATTENDANCE = '/attendance';
  static const LEAVE = '/leave';
  static const PERFORMANCE = '/performance';
  static const PERFORMANCE_DETAIL = '/performance-detail';
  static const SALARY = '/salary';
  static const SALARY_DETAIL = '/salary-detail';
  static const RESUME_LIST = '/resume-list';
  static const RESUME_ONLINE_EDIT = '/resume-online-edit';
  static const RESUME_ONLINE_VIEW = '/resume-online-view';
  static const RESUME_ATTACHMENT_UPLOAD = '/resume-attachment-upload';
  static const RESUME_ATTACHMENT_VIEW = '/resume-attachment-view';
}
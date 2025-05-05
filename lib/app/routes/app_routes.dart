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
}
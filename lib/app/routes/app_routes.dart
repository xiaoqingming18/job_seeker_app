part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const HOME = _Paths.HOME;
  static const PROFILE_EDIT = _Paths.PROFILE_EDIT;
  static const SETTINGS = _Paths.SETTINGS;
  static const JOB_DETAIL = _Paths.JOB_DETAIL;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const HOME = '/home';
  static const PROFILE_EDIT = '/profile-edit';
  static const SETTINGS = '/settings';
  static const JOB_DETAIL = '/job-detail';
}
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const AUTH = _Paths.AUTH;
  static const HOME = _Paths.HOME;
}

abstract class _Paths {
  _Paths._();
  static const AUTH = '/auth';
  static const HOME = '/home';
}
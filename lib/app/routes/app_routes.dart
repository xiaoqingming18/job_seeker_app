part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const AUTH = _Paths.AUTH;
}

abstract class _Paths {
  _Paths._();
  static const AUTH = '/auth';
}
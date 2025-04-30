import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/job_detail/bindings/job_detail_binding.dart';
import '../modules/job_detail/views/job_detail_view.dart';
import '../modules/my_applications/bindings/my_applications_binding.dart';
import '../modules/my_applications/views/my_applications_view.dart';
import '../modules/profile_edit/bindings/profile_edit_binding.dart';
import '../modules/profile_edit/views/profile_edit_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/contract/views/contract_sign_view.dart';
import '../modules/contract/controllers/contract_sign_controller.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_EDIT,
      page: () => const ProfileEditView(),
      binding: ProfileEditBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.JOB_DETAIL,
      page: () => const JobDetailView(),
      binding: JobDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.MY_APPLICATIONS,
      page: () => const MyApplicationsView(),
      binding: MyApplicationsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.CONTRACT_SIGN,
      page: () => const ContractSignView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ContractSignController>(
          () => ContractSignController(
            contractCode: Get.parameters['contractCode'] ?? '',
          ),
        );
      }),
    ),
  ];
}
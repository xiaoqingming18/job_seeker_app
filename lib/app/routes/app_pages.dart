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
import '../modules/chat_detail/views/chat_detail_view.dart';
import '../modules/chat_detail/bindings/chat_detail_binding.dart';
import '../modules/labor_demand_search/views/labor_demand_search_view.dart';
import '../modules/labor_demand_search/bindings/labor_demand_search_binding.dart';
import '../modules/test/views/notification_test_view.dart';
import '../modules/attendance/views/attendance_view.dart';
import '../modules/attendance/bindings/attendance_binding.dart';
import '../modules/leave/views/leave_view.dart';
import '../modules/leave/bindings/leave_binding.dart';
import '../modules/performance/views/performance_view.dart';
import '../modules/performance/views/performance_detail_view.dart';
import '../modules/performance/bindings/performance_binding.dart';
import '../modules/performance/bindings/performance_detail_binding.dart';
import '../modules/salary/views/salary_view.dart';
import '../modules/salary/views/salary_detail_view.dart';
import '../modules/salary/bindings/salary_binding.dart';
import '../modules/salary/bindings/salary_detail_binding.dart';
import '../modules/resume/views/resume_list_view.dart';
import '../modules/resume/views/resume_online_edit_view.dart';
import '../modules/resume/views/resume_online_view_view.dart';
import '../modules/resume/views/resume_attachment_upload_view.dart';
import '../modules/resume/views/resume_attachment_view_view.dart';
import '../modules/resume/bindings/resume_list_binding.dart';
import '../modules/resume/bindings/resume_online_edit_binding.dart';
import '../modules/resume/bindings/resume_online_view_binding.dart';
import '../modules/resume/bindings/resume_attachment_upload_binding.dart';
import '../modules/resume/bindings/resume_attachment_view_binding.dart';
import '../modules/certificate/views/certificate_list_view.dart';
import '../modules/certificate/views/certificate_edit_view.dart';
import '../modules/certificate/bindings/certificate_list_binding.dart';
import '../modules/certificate/bindings/certificate_edit_binding.dart';

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
    GetPage(
      name: _Paths.CHAT_DETAIL,
      page: () => const ChatDetailView(),
      binding: ChatDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.LABOR_DEMAND_SEARCH,
      page: () => const LaborDemandSearchView(),
      binding: LaborDemandSearchBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_TEST,
      page: () => const NotificationTestView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.ATTENDANCE,
      page: () => const AttendanceView(),
      binding: AttendanceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.LEAVE,
      page: () => const LeaveView(),
      binding: LeaveBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.PERFORMANCE,
      page: () => const PerformanceView(),
      binding: PerformanceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.PERFORMANCE_DETAIL,
      page: () => const PerformanceDetailView(),
      binding: PerformanceDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.SALARY,
      page: () => const SalaryView(),
      binding: SalaryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.SALARY_DETAIL,
      page: () => const SalaryDetailView(),
      binding: SalaryDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.RESUME_LIST,
      page: () => const ResumeListView(),
      binding: ResumeListBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.RESUME_ONLINE_EDIT,
      page: () => const ResumeOnlineEditView(),
      binding: ResumeOnlineEditBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.RESUME_ONLINE_VIEW,
      page: () => const ResumeOnlineViewView(),
      binding: ResumeOnlineViewBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.RESUME_ATTACHMENT_UPLOAD,
      page: () => const ResumeAttachmentUploadView(),
      binding: ResumeAttachmentUploadBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.RESUME_ATTACHMENT_VIEW,
      page: () => const ResumeAttachmentViewView(),
      binding: ResumeAttachmentViewBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.CERTIFICATE_LIST,
      page: () => const CertificateListView(),
      binding: CertificateListBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.CERTIFICATE_EDIT,
      page: () => const CertificateEditView(),
      binding: CertificateEditBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
  ];
}
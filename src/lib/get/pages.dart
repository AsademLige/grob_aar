import 'package:get/get.dart';
import 'package:grob_aar/pages/root_page.dart';
import 'package:grob_aar/pages/scene_page.dart';
import 'package:grob_aar/pages/settings_page.dart';

class Routes {
  static const MAIN = '/main';
  static const SCENE = '/scene';
  static const SETTINGS = '/settings';
}

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.MAIN,
      page: () => const RootPage(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsPage(),
    ),
    GetPage(
      name: Routes.SCENE,
      page: () => const ScenePage(),
    ),
  ];
}

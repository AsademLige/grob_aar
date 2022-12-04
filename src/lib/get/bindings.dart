import 'package:get/get.dart';
import 'package:grob_aar/get/controllers/root_controller.dart';
import 'package:grob_aar/get/controllers/scene_controller.dart';
import 'package:grob_aar/get/controllers/settings_controller.dart';
import 'package:grob_aar/widgets/ar_scene/ar_scene_controller.dart';
import 'package:grob_aar/widgets/settings/other_settings/other_settings_controller.dart';
import 'package:grob_aar/widgets/settings/photo_settings/photo_settings_controller.dart';
import 'package:grob_aar/widgets/settings/voice_settings/voice_settings_controller.dart';

class Binding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(
      () => RootController(),
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
      fenix: true,
    );
    Get.lazyPut<SceneController>(
      () => SceneController(),
    );
    Get.lazyPut<VoiceSettingsController>(
      () => VoiceSettingsController(),
      fenix: true,
    );
    Get.lazyPut<PhotoSettingsController>(
      () => PhotoSettingsController(),
      fenix: true,
    );
    Get.lazyPut<OtherSettingsController>(
      () => OtherSettingsController(),
      fenix: true,
    );
    Get.put<ARSceneController>(
      ARSceneController(),
    );
  }
}

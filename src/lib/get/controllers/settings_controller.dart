import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grob_aar/get/pages.dart';
import 'package:grob_aar/widgets/settings/other_settings/other_settings_controller.dart';
import 'package:grob_aar/widgets/settings/photo_settings/photo_settings_controller.dart';
import 'package:grob_aar/widgets/settings/voice_settings/voice_settings_controller.dart';

class SettingsController extends GetxController {
  final VoiceSettingsController voiceCtrl = Get.find();
  final PhotoSettingsController photoCtrl = Get.find();
  final OtherSettingsController otherCtrl = Get.find();

  startFuneral() {
    if (photoCtrl.croppedFile == null) {
      Get.showSnackbar(const GetSnackBar(
        duration: Duration(seconds: 3),
        messageText: Text("Загрузите фотографию покойника"),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      ));
    } else {
      Get.find<VoiceSettingsController>().stop();
      Get.toNamed(
        Routes.SCENE,
        arguments: {
          "photoPath": photoCtrl.croppedFile!.path,
          "bgMusicPath": otherCtrl.bgMusicPath,
          "voiceString": voiceCtrl.voiceText,
        },
      );
    }
  }
}

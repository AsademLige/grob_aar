import 'package:flutter_svg/svg.dart';
import 'package:grob_aar/themes/color_alias.dart';
import 'package:grob_aar/widgets/settings/other_settings/other_setting.dart';
import 'package:grob_aar/widgets/settings/voice_settings/voice_settings.dart';
import 'package:grob_aar/widgets/settings/photo_settings/photo_settings.dart';
import 'package:grob_aar/get/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Подготовка похорон"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PhotoSettings(
              margin: EdgeInsets.all(16),
            ),
            const VoiceSettings(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            ),
            const OtherSettings(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ElevatedButton.icon(
                onPressed: controller.startFuneral,
                icon: SvgPicture.asset(
                  "assets/icons/showel.svg",
                  width: 20,
                  height: 20,
                  color: ColorAlias.textPrimary,
                ),
                label: const Text('Приступить к похоронам'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

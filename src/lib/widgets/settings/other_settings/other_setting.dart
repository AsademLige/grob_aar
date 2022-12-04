import 'package:grob_aar/widgets/settings/other_settings/other_settings_controller.dart';
import 'package:grob_aar/themes/color_alias.dart';
import 'package:grob_aar/data/music_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtherSettings extends GetView<OtherSettingsController> {
  final EdgeInsets margin;

  const OtherSettings({
    Key? key,
    this.margin = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: controller,
        builder: (_) => Container(
            margin: margin,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                border: Border.all(
                  color: Get.theme.primaryColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Настройте свою атмосферу на мероприятии",
                    style: TextStyle(
                      color: ColorAlias.textSecondary.withAlpha(100),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Obx(
                        () => CupertinoSwitch(
                          activeColor: ColorAlias.buttonPrimary,
                          value: controller.playCry.value,
                          onChanged: controller.onCryChanged,
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: const Text('Рыдания по ушедшему'))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Obx(
                        () => CupertinoSwitch(
                            activeColor: ColorAlias.buttonPrimary,
                            value: controller.showWreath.value,
                            onChanged: controller.onShowWreathChanged),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: const Text('Погребальный венок'))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Obx(
                        () => CupertinoSwitch(
                          activeColor: ColorAlias.buttonPrimary,
                          value: controller.playMusic.value,
                          onChanged: controller.onMusicChanged,
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: const Text('Исполнение музыки'))
                    ],
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: controller.playMusic.value,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: 'Выбор музыкального сопровождения',
                          labelStyle: TextStyle(
                              color: ColorAlias.textPrimary.withAlpha(100))),
                      value: MusicAssets.list.keys.first,
                      items: MusicAssets.list.keys
                          .map((key) => DropdownMenuItem(
                                child: Text(MusicAssets.list[key]!),
                                value: key,
                              ))
                          .toList(),
                      onChanged: (String? path) {
                        controller.bgMusicPath = path!;
                      },
                    ),
                  ),
                ),
              ],
            )));
  }
}

import 'package:get/get.dart';
import 'package:grob_aar/themes/color_alias.dart';
import 'package:grob_aar/widgets/settings/voice_settings/voice_settings_controller.dart';
import 'package:flutter/material.dart';

class VoiceSettings extends GetView<VoiceSettingsController> {
  final EdgeInsets margin;
  const VoiceSettings({
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
                "Последние слова для усопшего...",
                style: TextStyle(
                  color: ColorAlias.textSecondary.withAlpha(100),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            _inputSection(),
            _voiceSection(),
            _btnSection()
          ],
        ),
      ),
    );
  }

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      child: TextField(
        maxLines: 11,
        minLines: 6,
        decoration: InputDecoration(
          hintText: 'Речь',
          hintStyle: TextStyle(
            color: ColorAlias.textPrimary.withAlpha(100),
          ),
        ),
        onChanged: (String value) {
          controller.onChange(value);
        },
      ));

  Widget _voiceSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: GetBuilder(
        init: controller,
        builder: (_) {
          if (controller.voices.isNotEmpty) {
            return DropdownButtonFormField<Map<String, String>>(
              decoration: InputDecoration(
                  labelText: 'Выбор музыкального сопровождения',
                  labelStyle:
                      TextStyle(color: ColorAlias.textPrimary.withAlpha(100))),
              value: controller.voices.first,
              items: controller.voices
                  .map((value) => DropdownMenuItem(
                        child:
                            Text("Голос ${controller.voices.indexOf(value)}"),
                        value: value,
                      ))
                  .toList(),
              onChanged: (Map<String, String>? voice) =>
                  controller.setVoice(voice!),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _btnSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(ColorAlias.buttonPrimary, ColorAlias.buttonPrimary,
            Icons.play_arrow, 'Прочесть', controller.speak),
        _buildButtonColumn(
            Colors.white, Colors.white, Icons.stop, 'Стоп', controller.stop),
      ],
    );
  }

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }
}

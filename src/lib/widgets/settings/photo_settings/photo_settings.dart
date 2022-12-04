import 'package:grob_aar/themes/color_alias.dart';
import 'package:grob_aar/widgets/settings/photo_settings/photo_settings_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class PhotoSettings extends GetView<PhotoSettingsController> {
  final EdgeInsets margin;

  const PhotoSettings({
    Key? key,
    this.margin = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) => Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          border: Border.all(
            color: Get.theme.primaryColor,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.all(8),
              child: Text(
                "* Выбор фотографии для похорон",
                style: TextStyle(
                  color: ColorAlias.textSecondary.withAlpha(100),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            _body(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (controller.croppedFile != null || controller.pickedFile != null) {
      return _imageCard();
    } else {
      return _uploaderCard();
    }
  }

  Widget _imageCard() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _image(),
              ),
            ),
          ),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = Get.size.width;
    final screenHeight = Get.size.height;
    if (controller.croppedFile != null) {
      final path = controller.croppedFile!.path;
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        clipBehavior: Clip.hardEdge,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 0.8 * screenWidth,
              maxHeight: 0.7 * screenHeight,
            ),
            child: Image.file(File(path)),
          ),
          Image.asset(
            "assets/images/lenta.png",
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ],
      );
    } else if (controller.pickedFile != null) {
      final path = controller.pickedFile!.path;
      return Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 0.8 * screenWidth,
              maxHeight: 0.7 * screenHeight,
            ),
            child: Image.file(File(path)),
          ),
          Transform.rotate(
            child: Image.asset(
              "assets/images/lenta.png",
              width: 40,
              height: 200,
              fit: BoxFit.cover,
            ),
            angle: 0.45,
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              controller.clear();
            },
            backgroundColor: ColorAlias.buttonPrimary,
            tooltip: 'Удалить',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Widget _uploaderCard() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DottedBorder(
            radius: const Radius.circular(12.0),
            borderType: BorderType.RRect,
            dashPattern: const [8, 4],
            color: Theme.of(Get.context!).highlightColor.withOpacity(0.4),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    color: Theme.of(Get.context!).highlightColor,
                    size: 120.0,
                  ),
                  const SizedBox(height: 40.0),
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: Text(
                      'Загрузите фото усопшего',
                      style: Theme.of(Get.context!)
                          .textTheme
                          .bodyText2
                          ?.copyWith(
                              color: Theme.of(Get.context!).highlightColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            onPressed: () async {
              await controller.uploadImage();
              try {
                controller.cropImage();
              } catch (_) {}
            },
            child: const Text('Выбрать'),
          ),
        ),
      ],
    );
  }
}

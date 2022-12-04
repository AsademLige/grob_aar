import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grob_aar/themes/color_alias.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PhotoSettingsController extends GetxController {
  XFile? pickedFile;
  CroppedFile? croppedFile;

  Future<void> cropImage() async {
    if (pickedFile != null) {
      final _croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Фото усопшего',
              toolbarColor: ColorAlias.primaryDark,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true),
          IOSUiSettings(
            title: 'Фото усопшего',
          ),
        ],
      );
      if (_croppedFile != null) {
        croppedFile = _croppedFile;
        update();
      }
    }
  }

  Future<void> uploadImage() async {
    final _pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (_pickedFile != null) {
      pickedFile = _pickedFile;
      update();
    }
  }

  void clear() {
    pickedFile = null;
    croppedFile = null;
    update();
  }
}

import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grob_aar/themes/color_alias.dart';
import 'package:grob_aar/widgets/ar_scene/ar_scene_controller.dart';

class ARScene extends GetView<ARSceneController> {
  ARScene(
      {Key? key,
      required PlaneDetectionConfig detectionConfig,
      String? bgMusicPath,
      String? voiceText,
      required String photoPath})
      : super(key: key) {
    controller.detectionConfig = detectionConfig;
    controller.bgMusicPath = bgMusicPath;
    controller.voiceText = voiceText;
    controller.photoPath = photoPath;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ARSceneController>(
      init: controller,
      builder: (_) {
        return Stack(children: [
          ARView(
              onARViewCreated: controller.onARViewCreated,
              planeDetectionConfig: controller.detectionConfig),
          GetBuilder<ARSceneController>(
              init: controller,
              builder: (_) => Visibility(
                  visible: controller.loading != 100,
                  child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Подвозим гроб...",
                              style: TextStyle(
                                  color: ColorAlias.textPrimary,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                width: 300,
                                height: 10,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: LinearProgressIndicator(
                                      value: controller.loadingAnim.value,
                                      color: ColorAlias.buttonPrimary,
                                      backgroundColor: ColorAlias.textSecondary,
                                      semanticsLabel: 'Модель загружается',
                                    )),
                              )),
                        ],
                      )))),
          IgnorePointer(
              child: Obx(() => Visibility(
                  visible: (controller.showTapHelping.value &&
                          !controller.showPlaneHelping.value) ||
                      (controller.showTapHelping.value &&
                          controller.detectionConfig ==
                              PlaneDetectionConfig.none),
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/gesture.png",
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                    ),
                  )))),
          IgnorePointer(
              child: Obx(() => Visibility(
                  visible: controller.showPlaneHelping.value &&
                      (controller.detectionConfig != PlaneDetectionConfig.none),
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/phone.png",
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                    ),
                  ))))
        ]);
      },
    );
  }
}

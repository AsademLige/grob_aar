import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grob_aar/get/controllers/scene_controller.dart';
import 'package:grob_aar/widgets/ar_scene/ar_scene.dart';

class ScenePage extends GetView<SceneController> {
  const ScenePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARScene(
        detectionConfig: PlaneDetectionConfig.horizontalAndVertical,
        voiceText: Get.arguments["voiceString"],
        bgMusicPath: Get.arguments["bgMusicPath"],
        photoPath: Get.arguments["photoPath"],
      ),
    );
  }
}

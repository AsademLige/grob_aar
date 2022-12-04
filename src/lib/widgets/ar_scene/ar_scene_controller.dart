import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_scene_manager/utils/node_factory.dart';
import 'package:ar_scene_manager/utils/scene_loader.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:grob_aar/widgets/settings/other_settings/other_settings_controller.dart';
import 'package:grob_aar/widgets/settings/voice_settings/voice_settings_controller.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class TickerCreator implements TickerProvider {
  @override
  Ticker createTicker(void Function(Duration elapsed) onTick) => Ticker(onTick);
}

class ARSceneController extends SuperController with TickerCreator {
  PlaneDetectionConfig detectionConfig =
      PlaneDetectionConfig.horizontalAndVertical;

  List<ARNode> preloadedNodes = [];

  Map<String, dynamic>? curNodeData;
  RxBool showPlaneHelping = true.obs;
  RxBool showTapHelping = false.obs;

  String? bgMusicPath;
  String? voiceText;
  String? photoPath;

  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  double loading = 100;
  late AnimationController loadingAnim;

  final String iosScenePath = "assets/scenes/ios.arscene";
  final String androidScenePath = "assets/scenes/toGrave.arscene";

  void onARViewCreated(
      {required ARSessionManager arSessionManager,
      required ARObjectManager arObjectManager,
      required ARAnchorManager arAnchorManager,
      required ARLocationManager arLocationManager,
      int frameRate = 120}) async {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
        customPlaneTexturePath: "assets/images/triangle.png",
        showFeaturePoints: false,
        showWorldOrigin: false,
        showPlanes: false,
        maxFrameRate: 120,
        handlePans: false,
        handleRotation: false);

    this.arObjectManager!.onInitialize();
    this.arObjectManager!.onNodeTap = onNodeTap;
    this.arObjectManager!.onNodeDoubleTap = onNodeDoubleTap;
    this.arObjectManager!.onNodeLongTap = onNodeLongTap;

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arSessionManager!.onPlaneDetected = onPlaneDetected;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;

    Get.showSnackbar(const GetSnackBar(
      duration: Duration(seconds: 5),
      messageText: Text("Найдите ровную поверхность для установки гроба"),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    ));
  }

  Future<void> preloadScene(String scenePath) async {
    preloadedNodes =
        await SceneLoader.loadNodes(scenePath, fromFlutterAssets: true);

    for (var node in preloadedNodes) {
      NodeFactory.addNode(node: node, arObjectManager: arObjectManager!);
    }

    loading = 100;
    update();
  }

  onNodeTap(List<String> nodesNames) {}

  onNodeDoubleTap(List<String> nodesNames) {}

  onNodeLongTap(List<String> nodesNames) {}

  onNodeChoisedInMenu(ARNode node) {
    curNodeData = node.toMap();
    showTapHelping.value = true;
  }

  onPanStarted(String nodeName) {}

  onPanChanged(String nodeName) {}

  onPanEnded(String nodeName, Matrix4 newTransform) {}

  onRotationStarted(String nodeName) {}

  onRotationChanged(String nodeName) {}

  onRotationEnded(String nodeName, Matrix4 newTransform) {}

  Future<void> onPlaneDetected() async {
    showPlaneHelping.value = false;
    showTapHelping.value = true;

    Get.closeCurrentSnackbar();

    Get.showSnackbar(const GetSnackBar(
      duration: Duration(seconds: 5),
      messageText: Text("Установите гроб"),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    ));
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> tapResults) async {
    loading = 0.0;

    preloadedNodes = await SceneLoader.loadNodes(
        Platform.isAndroid ? androidScenePath : iosScenePath,
        fromFlutterAssets: true);

    ARHitTestResult tapPos = tapResults
        .firstWhere((tapResult) => tapResult.type == ARHitTestResultType.plane);

    showTapHelping.value = false;

    for (var node in preloadedNodes) {
      ARNode? photo = NodeFactory.findNodeByName(node, "photo");
      ARNode? wreath = NodeFactory.findNodeByName(node, "#wreath");

      if (!Get.find<OtherSettingsController>().showWreath.value) {
        wreath!.isEnabled = false;
      }

      photo!.uri = photoPath;
      photo.type = NodeType.fileSystemAppFolderImage;
      photo.scale = Vector3(1, 1, 1);

      node.scale = Vector3(2.0, 2.0, 2.0);
      NodeFactory.addNodeWithAnchor(
        worldPos: tapPos.worldTransform,
        arAnchorManager: arAnchorManager!,
        arObjectManager: arObjectManager!,
        node: node,
      );
    }

    loading = 100;

    update();

    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (Get.find<OtherSettingsController>().playCry.value) {
        NodeFactory.addNode(
            node: ARNode.mediaNode(uri: "assets/music/cry.mp3", volume: 5),
            arObjectManager: arObjectManager!);
      }

      if (Get.find<OtherSettingsController>().playMusic.value) {
        NodeFactory.addNode(
            node: ARNode.mediaNode(uri: bgMusicPath, volume: 10),
            arObjectManager: arObjectManager!);
      }
    });

    Future.delayed(const Duration(milliseconds: 8000), () async {
      Get.find<VoiceSettingsController>().speak();
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadingAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        update();
      });
    loadingAnim.forward();
  }

  @override
  onClose() {
    super.onClose();
    Get.find<VoiceSettingsController>().stop();
    if (Platform.isAndroid) arSessionManager!.dispose();
  }

  @override
  onDetached() {}

  @override
  onInactive() {}

  @override
  onPaused() {}

  @override
  onResumed() {}
}

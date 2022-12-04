import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModelSettingsController extends GetxController {
  final PageController pageCtrl = PageController();
  ARObjectManager? arObjectManager;

  Rx<Color> rxColor = const Color(0xFF000000).obs;
  Rx<Color> rxBgClor = const Color(0xFF000000).obs;

  RxString dpdValue = "".obs;

  RxBool isEnabled = true.obs;
  RxBool isPlaying = true.obs;
  RxBool isAnimated = true.obs;
  RxBool linkScale = true.obs;

  RxDouble nodeXPos = 0.0.obs;
  RxDouble nodeYPos = 0.0.obs;
  RxDouble nodeZPos = 0.0.obs;

  RxDouble nodeXScale = 0.0.obs;
  RxDouble nodeYScale = 0.0.obs;
  RxDouble nodeZScale = 0.0.obs;

  RxDouble nodeXAngle = 0.0.obs;
  RxDouble nodeYAngle = 0.0.obs;
  RxDouble nodeZAngle = 0.0.obs;

  RxDouble posVel = 0.005.obs;
  RxDouble scaleVel = 0.005.obs;
  RxDouble angleVel = 0.005.obs;
  RxDouble whVel = 5.0.obs;

  RxDouble nodeWidth = 100.0.obs;
  RxDouble nodeheight = 50.0.obs;

  RxInt volumeVal = 100.obs;

  initial(ARNode node) {
    nodeXPos.value = node.position.x;
    nodeYPos.value = node.position.y;
    nodeZPos.value = node.position.z;

    nodeXScale.value = node.scale.x;
    nodeYScale.value = node.scale.y;
    nodeZScale.value = node.scale.z;

    scaleVel.value = node.scale.x * 0.001;

    nodeXAngle.value = node.eulerAngles.x;
    nodeYAngle.value = node.eulerAngles.y;
    nodeZAngle.value = node.eulerAngles.z;

    isEnabled.value = node.isEnabled;
    if (node.isModel()) isAnimated.value = node.isAnimated;
    if (node.isMedia()) {
      isPlaying.value = node.isPlaying;
      volumeVal.value = node.volume;
    }
    dpdValue.value = node.id;

    if (node.isText()) {
      rxColor.value = node.color;
      rxBgClor.value = node.bgColor;
    }

    ARNode? parent = arObjectManager!.getParent(node);
    dpdValue.value = (parent != null) ? parent.id : node.id;
  }

  toggleLinkScale() {
    linkScale.value = !linkScale.value;
  }

  toggleEnagled() {
    isEnabled.value = !isEnabled.value;
  }

  dpdValueChange(String? value) {
    dpdValue.value = value!;
  }

  translateX(ARNode node, {double? x}) {
    nodeXPos.value += x ?? posVel.value;
    node.translateX(nodeXPos.value);
  }

  translateY(ARNode node, {double? y}) {
    nodeYPos.value += y ?? posVel.value;
    node.translateY(nodeYPos.value);
  }

  translateZ(ARNode node, {double? z}) {
    nodeZPos.value += z ?? posVel.value;
    node.translateZ(nodeZPos.value);
  }

  rotateX(ARNode node, {double? rX}) {
    nodeXAngle.value += rX ?? angleVel.value;
    node.rotateX(nodeXAngle.value);
  }

  rotateY(ARNode node, {double? rY}) {
    nodeYAngle.value += rY ?? angleVel.value;
    node.rotateY(nodeYAngle.value);
  }

  rotateZ(ARNode node, {double? rZ}) {
    nodeZAngle.value += rZ ?? angleVel.value;
    node.rotateZ(nodeZAngle.value);
  }

  fixRotate(ARNode node) {
    rotateX(node, rX: 0.0);
    rotateY(node, rY: 0.0);
    rotateZ(node, rZ: 0.0);
  }

  scale(ARNode node, {double? scale}) {
    if (nodeXScale.value + (scale ?? scaleVel.value) <= 0 ||
        nodeYScale.value + (scale ?? scaleVel.value) <= 0 ||
        nodeZScale.value + (scale ?? scaleVel.value) <= 0) {
      return;
    }

    nodeXScale.value += scale ?? scaleVel.value;
    nodeYScale.value += scale ?? scaleVel.value;
    nodeZScale.value += scale ?? scaleVel.value;

    node.scale = Vector3(nodeXScale.value, nodeYScale.value, nodeZScale.value);
  }

  scaleX(ARNode node, {double? x}) {
    if (nodeXScale.value + (x ?? scaleVel.value) <= 0) {
      return;
    }
    nodeXScale.value += x ?? scaleVel.value;
    node.scaleX(nodeXScale.value);
  }

  scaleY(ARNode node, {double? y}) {
    if (nodeYScale.value + (y ?? scaleVel.value) <= 0) {
      return;
    }
    nodeYScale.value += y ?? scaleVel.value;
    node.scaleY(nodeYScale.value);
  }

  scaleZ(ARNode node, {double? z}) {
    if (nodeZScale.value + (z ?? scaleVel.value) <= 0) {
      return;
    }
    nodeZScale.value += z ?? scaleVel.value;
    node.scaleZ(nodeZScale.value);
  }

  volume(ARNode node, {int vol = 0}) {
    if (volumeVal.value + vol < 0 || volumeVal.value + vol > 100) {
      return;
    }
    volumeVal.value += vol;
    node.volume = volumeVal.value;
  }

  width(ARNode node, {double? w}) {
    if (nodeWidth.value + (w ?? whVel.value) <= 0) {
      return;
    }
    nodeWidth.value += w ?? whVel.value;
    node.width = nodeWidth.value.truncate();
  }

  height(ARNode node, {double? h}) {
    if (nodeheight.value + (h ?? whVel.value) <= 0) {
      return;
    }
    nodeheight.value += h ?? whVel.value;
    node.height = nodeheight.value.truncate();
  }

  IconData getNodeTreeIcon(String id) {
    ARNode? node = arObjectManager!.getNodeById(id);
    if (node!.isAudio()) {
      if (isEnabled.value) {
        return Icons.pause;
      } else {
        return Icons.play_circle_outline;
      }
    } else {
      if (isEnabled.value) {
        return Icons.lightbulb;
      } else {
        return Icons.lightbulb_outline;
      }
    }
  }
}

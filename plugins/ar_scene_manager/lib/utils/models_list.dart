import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_scene_manager/models/arnode_data.dart';
import 'package:ar_scene_manager/utils/save_utils.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ModelsList {
  static Future<List<ARNodeData>> getModels() async {
    List<dynamic> nodesData = await SavedPrefs.getModels();
    List<ARNodeData> nodesList =
        nodesData.map((nodeData) => ARNodeData.fromMap(nodeData)).toList();
    for (var nodeData in _nodesListData) {
      nodesList.add(ARNodeData.clone(nodeData));
    }
    return nodesList;
  }

  static Future<ARNodeData?> getByNode(ARNode node) async {
    List<ARNodeData> models = await ModelsList.getModels();
    ARNodeData? nodeCardData;
    for (var model in models) {
      if (model.node.id == node.id) nodeCardData = model;
    }
    return nodeCardData;
  }

  static ARNodeData userModelData = ARNodeData(
      previewName: "user model",
      previewImgPath: "",
      isUserModel: true,
      node: ARNode.model3D(
          name: "#userModel",
          isAnimated: false,
          type: NodeType.localGBL,
          uri: "",
          scale: Vector3(1, 1, 1),
          position: Vector3(0.0, -0.2, -0.5),
          eulerAngles: Vector3(0.0, 0.0, 0.0)));

  static final List<ARNodeData> _nodesListData = [
    ARNodeData(
        previewName: "Текстовое поле",
        isUserModel: false,
        node: ARNode.textNode(
            name: "#text01",
            text: "Текстовое поле",
            color: const Color(0xFFFFFFFF),
            bgColor: const Color(0xFF333333).withAlpha(200),
            scale: Platform.isIOS
                ? Vector3(0.005, 0.005, 0.005)
                : Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    // ARNodeData(
    //     previewName: "display 01",
    //     previewImgPath: "assets/images/previews/display.png",
    //     isUserModel: false,
    //     node: ARNode.model3D(
    //         name: "#display01",
    //         type: NodeType.localGBL,
    //         uri: "assets/models/display/scene.glb",
    //         scale: Vector3(1, 1, 1),
    //         position: Vector3(0.0, -0.2, -1),
    //         eulerAngles: Vector3(0.0, 0.0, 0.0))),
    ARNodeData(
        previewName: "mainScene 01",
        previewImgPath: "",
        isUserModel: false,
        node: ARNode.model3D(
            name: "#scene01",
            type: NodeType.localGBL,
            uri: "assets/models/scene/scene.glb",
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    ARNodeData(
        previewName: "button 01",
        previewImgPath: "",
        isUserModel: false,
        node: ARNode.model3D(
            name: "#podium01",
            type: NodeType.localGBL,
            uri: "assets/models/podium/podium.glb",
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    ARNodeData(
        previewName: "button tapped 01",
        previewImgPath: "",
        isUserModel: false,
        node: ARNode.model3D(
            name: "#podium01",
            type: NodeType.localGBL,
            uri: "assets/models/podium/podium_tapped.glb",
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    ARNodeData(
        previewName: "gerb 01",
        previewImgPath: "",
        isUserModel: false,
        node: ARNode.model3D(
            name: "#gerb01",
            type: NodeType.localGBL,
            uri: "assets/models/gerbRF/scene.gltf",
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    // ARNodeData(
    //     previewName: "stone 01",
    //     previewImgPath: "assets/images/previews/stone.png",
    //     isUserModel: false,
    //     node: ARNode.model3D(
    //         name: "#stone01",
    //         type: NodeType.localGBL,
    //         uri: "assets/models/stone/scene.glb",
    //         scale: Vector3(1, 1, 1),
    //         position: Vector3(0.0, -0.2, -1),
    //         eulerAngles: Vector3(0.0, 0.0, 0.0))),
    // ARNodeData(
    //     previewName: "sakura 01",
    //     previewImgPath: "assets/images/previews/sakura01.png",
    //     isUserModel: false,
    //     node: ARNode.model3D(
    //         name: "#sakura01",
    //         type: NodeType.localGBL,
    //         uri: "assets/models/sakura1/scene.glb",
    //         scale: Vector3(1, 1, 1),
    //         position: Vector3(0.05, -0.2, -1),
    //         eulerAngles: Vector3(0.0, 0.0, 0.0))),
    // ARNodeData(
    //     previewName: "sakura 02",
    //     previewImgPath: "assets/images/previews/sakura02.png",
    //     isUserModel: false,
    //     node: ARNode.model3D(
    //         name: "#sakura02",
    //         type: NodeType.localGBL,
    //         uri: "assets/models/sakura2/scene.glb",
    //         scale: Vector3(1, 1, 1),
    //         position: Vector3(0, -0.2, -1),
    //         eulerAngles: Vector3(0.0, 0.0, 0.0))),
    // ARNodeData(
    //     previewName: "ame 01",
    //     previewImgPath: "assets/images/previews/ame.png",
    //     isUserModel: false,
    //     node: ARNode.model3D(
    //         name: "#ame01",
    //         isAnimated: true,
    //         type: NodeType.localGBL,
    //         uri: "assets/models/ame/scene.glb",
    //         scale: Vector3(1, 1, 1),
    //         position: Vector3(0.08, -0.2, -1),
    //         eulerAngles: Vector3(0.0, 0.0, 0.0))),
    // ARNodeData(
    //     previewName: "dasha",
    //     previewImgPath: "assets/images/user.png",
    //     isUserModel: false,
    //     node: ARNode.imageNode(
    //         name: "#imgDasha01",
    //         type: NodeType.localImage,
    //         uri: "assets/images/user.png",
    //         scale: Vector3(1, 1, 1),
    //         position: Vector3(0.0, -0.2, -1),
    //         eulerAngles: Vector3(0.0, 0.0, 0.0))),
    ARNodeData(
        previewName: "green",
        previewImgPath: "assets/models/dis/green.png",
        isUserModel: false,
        node: ARNode.imageNode(
            name: "#green01",
            type: NodeType.localImage,
            uri: "assets/models/dis/green.png",
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    ARNodeData(
        previewName: "red",
        previewImgPath: "assets/models/dis/red.png",
        isUserModel: false,
        node: ARNode.imageNode(
            name: "#green01",
            type: NodeType.localImage,
            uri: "assets/models/dis/red.png",
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    ARNodeData(
        previewName: "hint",
        previewImgPath: "assets/models/dis/hint.png",
        isUserModel: false,
        node: ARNode.imageNode(
            name: "#hint01",
            type: NodeType.localImage,
            uri: "assets/models/dis/hint.png",
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -0.2, -1),
            eulerAngles: Vector3(0.0, 0.0, 0.0))),
    // ARNodeData(
    //     previewName: "cat",
    //     previewImgPath: "assets/images/previews/cat.png",
    //     isUserModel: false,
    //     node: ARNode.mediaNode(
    //         name: "#cat01",
    //         type: NodeType.localVideo,
    //         uri: "assets/videos/cat.mp4",
    //         scale: Vector3(1, 1, 1),
    //         position: Vector3(0.0, -0.2, -1),
    //         eulerAngles: Vector3(0.0, 0.0, 0.0)))
  ];
}

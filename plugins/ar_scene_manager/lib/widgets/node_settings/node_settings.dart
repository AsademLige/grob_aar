import 'package:ar_scene_manager/widgets/node_settings/text_settings_card.dart';
import 'package:ar_scene_manager/controllers/model_settings_controller.dart';
import 'package:ar_scene_manager/widgets/node_settings/transform_card.dart';
import 'package:ar_scene_manager/widgets/node_settings/params_card.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ar_scene_manager/classes/scene_manager.dart';
import 'package:ar_scene_manager/utils/node_helper.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_scene_manager/utils/nitifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NodeSettings extends GetView<ModelSettingsController> {
  final ARObjectManager arObjectManager;
  final ARAnchorManager anchorManager;
  final SceneManager sceneManager;
  final String nodeId;

  ARNode get node {
    return arObjectManager.getNodeById(nodeId)!;
  }

  NodeSettings(
      {Key? key,
      required this.anchorManager,
      required this.arObjectManager,
      required this.nodeId,
      required this.sceneManager})
      : super(key: key) {
    controller.arObjectManager = arObjectManager;
    controller.initial(node);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Icon(NodeHelper.getIconByType(node.type)),
              ),
              Text(NodeHelper.getNameByType(node.type)),
            ]),
            Visibility(
                visible: !node.isAudio(),
                child: Row(
                  children: [
                    Obx(() => Switch(
                          value: controller.isEnabled.value,
                          onChanged: (value) {
                            controller.toggleEnagled();
                            if (node.isAudio()) {
                              node.isPlaying = !node.isPlaying;
                            } else {
                              node.isEnabled = !node.isEnabled;
                            }
                          },
                          activeTrackColor: const Color(0xFFDDDDDD),
                          activeColor: const Color(0xFF555555),
                        )),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Obx(() => Icon(
                            controller.getNodeTreeIcon(nodeId),
                            color: const Color(0xFF555555),
                          )),
                    )
                  ],
                ))
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            children: [
              Flexible(
                  child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                height: 40,
                child: TextField(
                    autofocus: false,
                    textInputAction: TextInputAction.send,
                    autocorrect: false,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(9, 0, 8, 0),
                        filled: true,
                        fillColor: const Color(0xFFEEEEEE),
                        labelText:
                            (arObjectManager.getNodeById(node.id)!.name != "")
                                ? arObjectManager.getNodeById(node.id)!.name
                                : arObjectManager.getNodeById(node.id)!.id,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide:
                                BorderSide(color: Color(0xFFEEEEEE), width: 1)),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1)),
                        suffixIcon: IconButton(
                          color: const Color(0xFF555555),
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                        )),
                    onChanged: (String name) {
                      arObjectManager.getNodeById(node.id)!.name = name;
                    }),
              )),
              GestureDetector(
                onTap: () async {
                  ARNode cNode = ARNode.clone(node);
                  cNode.name = cNode.name + "Copy";
                  sceneManager.nodeChoised(cNode);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: const Icon(
                    Icons.copy_all_outlined,
                    color: Color(0xFF555555),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (await Utils.confirmDialog("Удаление",
                          "Удалить \"${(node.name != "") ? node.name : node.id}\" со сцены?") ??
                      false) {
                    arObjectManager.removeNode(node);
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFBBC05).withAlpha(200),
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: PageView(
                    controller: controller.pageCtrl,
                    scrollDirection: Axis.vertical,
                    children: []
                      ..addAllIf(() => !node.isAudio(), [
                        TransformCard(
                          cardIcon: Icons.open_with,
                          onUpdateX: (details) {
                            controller.translateX(node,
                                x: controller.posVel.value *
                                    details.delta.dx.sign);
                          },
                          onUpdateY: (details) {
                            controller.translateY(node,
                                y: controller.posVel.value *
                                    details.delta.dx.sign);
                          },
                          onUpdateZ: (details) {
                            controller.translateZ(node,
                                z: controller.posVel.value *
                                    details.delta.dx.sign);
                          },
                          onLeftXTap: () {
                            controller.posVel.value /= 2;
                          },
                          onRightXTap: () {
                            controller.posVel.value *= 2;
                          },
                          onLeftYTap: () {
                            controller.posVel.value /= 2;
                          },
                          onRightYTap: () {
                            controller.posVel.value *= 2;
                          },
                          onLeftZTap: () {
                            controller.posVel.value /= 2;
                          },
                          onRightZTap: () {
                            controller.posVel.value *= 2;
                          },
                          rxValue: controller.nodeXPos,
                          ryValue: controller.nodeYPos,
                          rzValue: controller.nodeZPos,
                        ),
                        TransformCard(
                          cardIcon: Icons.rotate_90_degrees_ccw,
                          onUpdateX: (details) {
                            controller.rotateX(node,
                                rX: controller.angleVel.value *
                                    details.delta.dx.sign);
                          },
                          onUpdateY: (details) {
                            controller.rotateY(node,
                                rY: controller.angleVel.value *
                                    details.delta.dx.sign);
                          },
                          onUpdateZ: (details) {
                            controller.rotateZ(node,
                                rZ: controller.angleVel.value *
                                    details.delta.dx.sign);
                          },
                          onLeftXTap: () {
                            controller.rotateX(node,
                                rX: -controller.angleVel.value * 100);
                          },
                          onRightXTap: () {
                            controller.rotateX(node,
                                rX: controller.angleVel.value * 100);
                          },
                          onLeftYTap: () {
                            controller.rotateY(node,
                                rY: -controller.angleVel.value * 100);
                          },
                          onRightYTap: () {
                            controller.rotateY(node,
                                rY: controller.angleVel.value * 100);
                          },
                          onLeftZTap: () {
                            controller.rotateZ(node,
                                rZ: -controller.angleVel.value * 100);
                          },
                          onRightZTap: () {
                            controller.rotateZ(node,
                                rZ: controller.angleVel.value * 100);
                          },
                          rxValue: controller.nodeXAngle,
                          ryValue: controller.nodeYAngle,
                          rzValue: controller.nodeZAngle,
                        ),
                        TransformCard(
                          cardIcon: Icons.zoom_out_map,
                          onUpdateX: (details) {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: controller.scaleVel.value *
                                      details.delta.dx.sign);
                            } else {
                              controller.scaleX(node,
                                  x: controller.scaleVel.value *
                                      details.delta.dx.sign);
                            }
                            controller.fixRotate(node);
                          },
                          onUpdateY: (details) {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: controller.scaleVel.value *
                                      details.delta.dx.sign);
                            } else {
                              controller.scaleY(node,
                                  y: controller.scaleVel.value *
                                      details.delta.dx.sign);
                            }
                            controller.fixRotate(node);
                          },
                          onUpdateZ: (details) {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: controller.scaleVel.value *
                                      details.delta.dx.sign);
                            } else {
                              controller.scaleZ(node,
                                  z: controller.scaleVel.value *
                                      details.delta.dx.sign);
                            }
                            controller.fixRotate(node);
                          },
                          onLeftXTap: () {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: -controller.scaleVel.value * 100);
                            } else {
                              controller.scaleX(node,
                                  x: -controller.scaleVel.value * 100);
                            }
                            controller.fixRotate(node);
                          },
                          onRightXTap: () {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: controller.scaleVel.value * 100);
                            } else {
                              controller.scaleX(node,
                                  x: controller.scaleVel.value * 100);
                            }
                            controller.fixRotate(node);
                          },
                          onLeftYTap: () {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: -controller.scaleVel.value * 100);
                            } else {
                              controller.scaleY(node,
                                  y: -controller.scaleVel.value * 100);
                            }
                            controller.fixRotate(node);
                          },
                          onRightYTap: () {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: controller.scaleVel.value * 100);
                            } else {
                              controller.scaleY(node,
                                  y: controller.scaleVel.value * 100);
                            }
                            controller.fixRotate(node);
                          },
                          onLeftZTap: () {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: -controller.scaleVel.value * 100);
                            } else {
                              controller.scaleZ(node,
                                  z: -controller.scaleVel.value * 100);
                            }
                            controller.fixRotate(node);
                          },
                          onRightZTap: () {
                            if (controller.linkScale.value) {
                              controller.scale(node,
                                  scale: controller.scaleVel.value * 100);
                            } else {
                              controller.scaleZ(node,
                                  z: controller.scaleVel.value * 100);
                            }
                            controller.fixRotate(node);
                          },
                          onLinkToggle: () => controller.toggleLinkScale(),
                          rxValue: controller.nodeXScale,
                          ryValue: controller.nodeYScale,
                          rzValue: controller.nodeZScale,
                          linkToggleValue: controller.linkScale,
                        )
                      ])
                      ..addAllIf(node.isText(), [
                        TransformCard(
                          cardIcon: Icons.format_shapes,
                          onUpdateX: (details) {
                            controller.width(node,
                                w: controller.whVel.value *
                                    details.delta.dx.sign);
                          },
                          onUpdateY: (details) {
                            controller.height(node,
                                h: controller.whVel.value *
                                    details.delta.dx.sign);
                          },
                          onLeftXTap: () {
                            controller.width(node,
                                w: -controller.whVel.value * 100);
                          },
                          onRightXTap: () {
                            controller.width(node,
                                w: controller.whVel.value * 100);
                          },
                          onLeftYTap: () {
                            controller.height(node,
                                h: -controller.whVel.value * 100);
                          },
                          onRightYTap: () {
                            controller.height(node,
                                h: controller.whVel.value * 100);
                          },
                          rxValue: controller.nodeWidth,
                          ryValue: controller.nodeheight,
                          xSuffix: "W :",
                          ySuffix: "H :",
                          alignment: CrossAxisAlignment.start,
                          digitsCount: 0,
                        ),
                        TextSettings(
                          arNode: node,
                          arObjectManager: arObjectManager,
                          rxBgClor: controller.rxBgClor,
                          rxColor: controller.rxColor,
                        )
                      ])
                      ..addAll([
                        ParamsCard(
                          arNode: node,
                          arObjectManager: arObjectManager,
                          dpdValue: controller.dpdValue,
                          volume: controller.volumeVal,
                          onVolumeUpdate: (details) {
                            controller.volume(node,
                                vol: (1 * details.delta.dx.sign).toInt());
                          },
                          onSetPlaying: () {
                            controller.isPlaying.value =
                                !controller.isPlaying.value;
                            node.isPlaying = !node.isPlaying;
                          },
                          isPlaying: controller.isPlaying,
                          isAnimated: controller.isAnimated,
                          onDpdValueChange: (String? value) {
                            controller.dpdValueChange(value);
                            arObjectManager.setParent(
                                parent: arObjectManager.getNodeById(value!)!,
                                child: arObjectManager.getNodeById(node.id)!);
                          },
                        )
                      ])),
              ),
              Visibility(
                  visible: !node.isAudio(),
                  child: Container(
                    width: 40,
                    decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Align(
                      alignment: Alignment.center,
                      child: SmoothPageIndicator(
                        controller: controller.pageCtrl,
                        count: (node.isText()) ? 6 : 4,
                        axisDirection: Axis.vertical,
                        effect: const ScrollingDotsEffect(
                            radius: 4,
                            dotHeight: 4,
                            dotWidth: 24,
                            dotColor: Color(0xFFDDDDDD),
                            activeDotColor: Color(0xFF555555)),
                      ),
                    ),
                  ))
            ],
          ),
        )),
      ],
    );
  }
}

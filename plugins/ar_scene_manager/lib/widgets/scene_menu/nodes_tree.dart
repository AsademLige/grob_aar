import 'package:ar_scene_manager/controllers/scene_menu_controller.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_scene_manager/classes/scene_manager.dart';
import 'package:ar_scene_manager/utils/nitifications.dart';
import 'package:ar_scene_manager/utils/node_helper.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NodesTree extends StatelessWidget {
  final SceneManager sceneManager;
  final ARObjectManager arObjectManager;
  final SceneMenuController controller;
  const NodesTree({
    Key? key,
    required this.controller,
    required this.arObjectManager,
    required this.sceneManager,
  }) : super(key: key);

  IconData getNodeTreeIcon(String id) {
    ARNode? node = arObjectManager.getNodeById(id);
    if (node == null) return Icons.lightbulb;
    if (node.isAudio()) {
      if (node.isPlaying) {
        return Icons.pause;
      } else {
        return Icons.play_arrow_rounded;
      }
    } else {
      if (node.isEnabled) {
        return Icons.lightbulb;
      } else {
        return Icons.lightbulb_outline;
      }
    }
  }

  List<Widget> getNodesTree(List<ARNode> list, {int level = 0}) {
    List<Widget> tree = [];
    for (var node in list) {
      tree.add(nodeInTree(node.id, level: level));
      tree.addAll(getNodesTree(node.children, level: level + 1));
    }
    return tree;
  }

  Widget nodeInTree(String id, {int level = 0}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: GestureDetector(
          onTap: () {
            Navigator.pop(Get.context!);
            sceneManager.showModelSettings(id);
          },
          child: Row(
            children: [
              (level > 0)
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      height: 5,
                      width: 15.0 * level,
                      decoration: const BoxDecoration(
                          color: Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                    )
                  : const Center(),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    decoration: const BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: Icon(NodeHelper.getIconByType(
                                  arObjectManager.getNodeById(id)!.type)),
                            ),
                            Text((arObjectManager.getNodeById(id)!.name != "")
                                ? arObjectManager.getNodeById(id)!.name
                                : arObjectManager.getNodeById(id)!.id)
                          ]),
                          GestureDetector(
                            onTap: () {
                              if (arObjectManager.getNodeById(id)!.isAudio()) {
                                arObjectManager.togglePlaying(id);
                              } else {
                                arObjectManager.toggleEnabled(id);
                              }
                              controller.update();
                            },
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: GetBuilder<SceneMenuController>(
                                init: controller,
                                builder: (value) => Icon(
                                  getNodeTreeIcon(id),
                                  color: const Color(0xFF555555),
                                ),
                              ),
                            ),
                          )
                        ]),
                  )),
                  GestureDetector(
                    onTap: () async {
                      ARNode node = arObjectManager.getNodeById(id)!;
                      if (await Utils.confirmDialog("Удаление",
                              "Удалить \"${(node.name != "") ? node.name : node.id}\" со сцены?") ??
                          false) {
                        arObjectManager.removeNode(node);
                        controller.update();
                      }
                    },
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF555555),
                        )),
                  )
                ],
              ))
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (arObjectManager.getNodes().isNotEmpty)
        ? GetBuilder(
            init: controller,
            builder: (_) {
              return Container(
                margin: const EdgeInsets.all(16),
                child: ListView(children: [
                  ...getNodesTree(arObjectManager
                      .getNodes(includeChildren: false)
                      .entries
                      .map((node) => node.value)
                      .toList())
                ]),
              );
            })
        : const Center(
            child: Text(
            "Сцена пуста",
            style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.w600,
                fontSize: 20),
          ));
  }
}

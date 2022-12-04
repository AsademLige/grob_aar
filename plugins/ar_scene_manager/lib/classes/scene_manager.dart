import 'package:ar_scene_manager/widgets/node_settings/node_settings.dart';
import 'package:ar_scene_manager/widgets/scene_menu/scene_menu.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_scene_manager/models/arnode_data.dart';
import 'package:ar_scene_manager/utils/models_list.dart';
import 'package:ar_scene_manager/models/scene_data.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef NodeChoisedInMenu = void Function(ARNode node);

class SceneManager {
  SceneManager(
      {required bool isEnabled,
      required ARObjectManager arObjectManager,
      required ARAnchorManager arAnchorManager,
      required ARSessionManager arSessionManager,
      SceneData? sceneData}) {
    _isEnabled = isEnabled;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;
    _arSessionManager = arSessionManager;
    _sceneData = sceneData ?? SceneData();
  }

  NodeChoisedInMenu? onNodeChoisedInMenu;

  bool _isEnabled = true;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;
  ARSessionManager? _arSessionManager;

  SceneData? _sceneData;

  bool get isEnabled {
    return _isEnabled;
  }

  set isEnabled(bool value) {
    if (value != _isEnabled) {
      _isEnabled = value;
    }
  }

  showSceneMenu() {
    if (!_isEnabled) return;
    showModalBottomSheet<void>(
        context: Get.context!,
        barrierColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (BuildContext context) {
          return SceneMenu(
            sceneManager: this,
            arObjectManager: _arObjectManager!,
            arSessionManager: _arSessionManager!,
          );
        });
  }

  showModelSettings(String id) {
    if (!_isEnabled || _arObjectManager!.getNodeById(id) == null) return;
    showModalBottomSheet<void>(
        context: Get.context!,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: .33,
            minChildSize: .1,
            maxChildSize: .5,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Column(children: [
                  GestureDetector(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                        height: 5,
                        width: 80,
                        decoration: const BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                    ),
                  ),
                  Expanded(
                      child: NodeSettings(
                    arObjectManager: _arObjectManager!,
                    anchorManager: _arAnchorManager!,
                    sceneManager: this,
                    nodeId: id,
                  ))
                ]),
              );
            },
          );
        });
  }

  nodeChoised(ARNode node) {
    if (onNodeChoisedInMenu != null && isEnabled) {
      onNodeChoisedInMenu!(node);
    }
  }

  Future<SceneData> getFullSceneData() async {
    List<ARNodeData> savedModels = await ModelsList.getModels();
    _sceneData!.clear();
    List<String> uniksId = [];
    _arObjectManager!.getNodes().forEach((key, node) async {
      for (var cModel in savedModels) {
        if (cModel.node.uri == node.uri && !uniksId.contains(node.id)) {
          ARNodeData model = ARNodeData.clone(cModel);
          model.node = node;
          uniksId.add(node.id);
          _sceneData!.addNodeData(model);
        }
      }
    });

    _arObjectManager!
        .getNodes(includeChildren: false)
        .forEach((key, node) async {
      _sceneData!.addSceneNode(node);
    });

    return _sceneData!;
  }

  SceneData getSceneData() {
    return _sceneData!;
  }
}

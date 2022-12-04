import 'package:ar_scene_manager/widgets/scene_menu/node_card.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_scene_manager/classes/scene_manager.dart';
import 'package:ar_scene_manager/utils/scene_loader.dart';
import 'package:ar_scene_manager/models/arnode_data.dart';
import 'package:ar_scene_manager/models/scene_data.dart';
import 'package:ar_scene_manager/utils/models_list.dart';
import 'package:ar_scene_manager/utils/node_helper.dart';
import 'package:ar_scene_manager/utils/save_utils.dart';
import 'package:ar_scene_manager/utils/nitifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SceneMenuController extends GetxController {
  List<NodeCard> _models = [];
  SceneManager? sceneManager;
  ARObjectManager? arObjectManager;
  String _filter = "";

  String get filter {
    return _filter;
  }

  set filter(String value) {
    if (value != _filter) {
      _filter = value;
      reload();
    }
  }

  void reload() async {
    List<ARNodeData> models = await ModelsList.getModels();

    _models = models
        .map((nodeData) => NodeCard(
              nodeData: ARNodeData.clone(nodeData),
              onTap: () => _onMenuModelTap(nodeData),
              onDelete: () async => _onMenuModelDelete(nodeData),
              onPickImage: () => _onUserModelPickImage(nodeData),
              onRename: (String name) => _onRenameNodeCard(nodeData, name),
            ))
        .toList()
      ..removeWhere((nodeCard) =>
          !nodeCard.nodeData.previewName.contains(filter) && filter != "");
    update();
  }

  List<Widget> get models {
    return _models;
  }

  void addUserModel(String path, String name, NodeType type,
      {List<String>? linkedFiles}) {
    path = path.replaceAll('(', '');
    path = path.replaceAll(')', '');

    ARNodeData nodeData = ARNodeData.clone(ModelsList.userModelData);

    nodeData.node.id = NodeHelper.getUniqNameByType(type);
    nodeData.node.uri = path;
    nodeData.node.type = type;
    nodeData.previewName = name;
    nodeData.linkedFiles = linkedFiles ?? [];
    if (nodeData.node.isImage()) {
      nodeData.previewImgPath = path;
    }

    _models.insert(
        0,
        NodeCard(
          nodeData: ARNodeData.clone(nodeData),
          onTap: () => _onMenuModelTap(nodeData),
          onDelete: () async => _onMenuModelDelete(nodeData),
          onPickImage: () => _onUserModelPickImage(nodeData),
          onRename: (String name) => _onRenameNodeCard(nodeData, name),
        ));
    SavedPrefs.saveModel(nodeData.toMap());
    update();
  }

  Future loadImages() async {
    List<dynamic> paths = await SceneLoader.pickFiles(['png', "jpg", "jpeg"]);
    for (var path in paths) {
      addUserModel(path[0], path[1], path[2]);
    }
  }

  Future loadAudio() async {
    List<dynamic> paths = await SceneLoader.pickFiles(['mp3']);
    for (var path in paths) {
      addUserModel(path[0], path[1], path[2]);
    }
  }

  Future loadVideo() async {
    List<dynamic> paths = await SceneLoader.pickFiles(['mp4']);
    for (var path in paths) {
      addUserModel(path[0], path[1], path[2]);
    }
  }

  Future loadGbl() async {
    List<dynamic> paths = await SceneLoader.pickGlb();
    for (var path in paths) {
      addUserModel(path[0], path[1], path[2]);
    }
  }

  Future loadGltf() async {
    List<dynamic> paths = await SceneLoader.pickGltf();
    for (var path in paths) {
      addUserModel(
        path[0],
        path[1],
        NodeType.fileSystemAppFolderGLTF2,
        linkedFiles: path[2],
      );
    }
  }

  Future<bool> saveScene() async {
    if (await Utils.confirmDialog(
            "Сохранение", "Сохранить сцену с текущими параметрами?") ??
        false) {
      SceneData data = await sceneManager!.getFullSceneData();
      data.path = await SceneLoader.saveScene(data);
      if (await SavedPrefs.saveScene(data.toMapHeaders())) {
        Utils.toast(" \"${data.name}\" cохранена");
        return true;
      }
    }
    return false;
  }

  Future<bool> shareScene() async {
    SceneData data = await sceneManager!.getFullSceneData();
    data.path = await SceneLoader.saveScene(data);
    await SceneLoader.shareFile(data.path);
    return true;
  }

  void _onRenameNodeCard(ARNodeData nodeData, String name) {
    nodeData.previewName = name;
    SavedPrefs.saveModel(nodeData.toMap());
    Navigator.of(Get.context!).pop();
    sceneManager!.showSceneMenu();
  }

  void _onMenuModelTap(ARNodeData nodeData) {
    filter = "";
    sceneManager!.nodeChoised(nodeData.node);
    Navigator.pop(Get.context!);
  }

  void _onUserModelPickImage(ARNodeData nodeData) async {
    List<dynamic> paths = await SceneLoader.pickFiles(['png', "jpg", "jpeg"],
        allowMultiple: false);
    for (var path in paths) {
      nodeData.previewImgPath = path[0];
      if (await SavedPrefs.saveModel(nodeData.toMap())) {
        reload();
      }
    }
  }

  void _onMenuModelDelete(ARNodeData nodeData) async {
    if (await Utils.confirmDialog("Удаление",
            "Вы действительно хотите удалить: \"${nodeData.previewName}\"") ??
        false) {
      if (await SavedPrefs.removeModelByName(nodeData.node.id)) {
        SceneLoader.garbageCollector();
        Utils.toast("${nodeData.previewName} - удалено успешно");
      } else {
        Utils.toast("Ошибка в процессе удаления");
      }
      reload();
    } else {
      Utils.toast("Удаление отменено");
    }
  }
}

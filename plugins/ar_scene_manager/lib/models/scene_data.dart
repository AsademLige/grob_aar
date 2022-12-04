import 'package:ar_scene_manager/models/arnode_data.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

class SceneData {
  String? _name;
  String? _path;
  int? _nodesCount;
  List<ARNodeData>? _nodesData;
  List<ARNode>? _sceneNodesList;

  SceneData(
      {String? name,
      String? path,
      List<ARNodeData>? nodesData,
      List<ARNode>? sceneNodesList}) {
    _name = name ?? "scene" + UniqueKey().toString();
    _nodesData = nodesData ?? [];
    _nodesCount = nodesCount;
    _sceneNodesList = sceneNodesList ?? [];
    _path = path;
  }

  String get path {
    return _path!;
  }

  set path(String value) {
    if (_path != value) _path = value;
  }

  String get name {
    return _name!;
  }

  set name(String value) {
    if (_name != value) {
      _name = value;
    }
  }

  int get nodesCount {
    return _getNodesCount(_sceneNodesList);
  }

  int _getNodesCount(List<ARNode>? initial) {
    if (initial == null) return 0;
    int count = 0;
    for (ARNode data in initial) {
      count++;
      count += _getNodesCount(data.children);
    }
    return count;
  }

  void addNodeData(ARNodeData nodeData) {
    _nodesData!.add(nodeData);
  }

  List<ARNodeData> getNodesData() {
    return _nodesData!;
  }

  void addSceneNode(ARNode node) {
    _nodesCount = _nodesCount! + 1;
    _sceneNodesList!.add(node);
  }

  List<ARNode> getSceneNodesList() {
    return _sceneNodesList!;
  }

  void clear() {
    _nodesData = [];
    _sceneNodesList = [];
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static SceneData fromMap(Map<String, dynamic> data) {
    List<ARNodeData> nodeDataList = (data["nodesData"] != null)
        ? List.from(data["nodesData"])
            .map((nodeData) => ARNodeData.fromMap(nodeData))
            .toList()
        : [];
    List<ARNode> sceneNodesList = (data["sceneNodesList"] != null)
        ? List.from(data["sceneNodesList"])
            .map((node) => ARNode.fromMap(node))
            .toList()
        : [];
    return SceneData(
        name: data["name"],
        path: data["path"],
        nodesData: nodeDataList,
        sceneNodesList: sceneNodesList);
  }

  static Future<SceneData?> fromUri(String path) async {
    try {
      File file = File(path);
      final dynamic content = jsonDecode(await file.readAsString());
      return SceneData.fromMap(content);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMapHeaders() => <String, dynamic>{
        "name": _name,
        "path": _path,
        "nodesCount": nodesCount,
      }..removeWhere((String k, dynamic v) => v == null);

  Map<String, dynamic> toMap() => <String, dynamic>{
        "name": _name,
        "nodesData": _nodesData!.map((nodeData) => nodeData.toMap()).toList(),
        "sceneNodesList": _sceneNodesList!.map((node) => node.toMap()).toList()
      }..removeWhere((String k, dynamic v) => v == null);
}

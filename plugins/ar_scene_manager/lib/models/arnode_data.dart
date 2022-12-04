import 'package:ar_flutter_plugin/utils/color_extension.dart';
import 'package:ar_flutter_plugin/utils/json_converters.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/cupertino.dart';

class ARNodeData {
  ARNode node;
  String? _previewName;
  String? _previewImgPath;
  String? _parentFile;
  bool? _isUserModel;
  List<String>? _linkedFiles;

  ARNodeData({
    required this.node,
    String? previewName,
    String? previewImgPath,
    String? parentFile,
    bool? isUserModel,
    List<String>? linkedFiles,
  }) {
    _previewName = previewName ?? "user model " + UniqueKey().toString();
    _previewImgPath = previewImgPath ?? "";
    _isUserModel = isUserModel ?? false;
    _parentFile = parentFile ?? "";
    _linkedFiles = linkedFiles ?? [];
  }

  String get previewName {
    return _previewName!;
  }

  set previewName(String value) {
    if (value != _previewName) {
      _previewName = value;
    }
  }

  String get parentFile {
    return _parentFile!;
  }

  set parentFile(String value) {
    if (value != _parentFile) {
      _parentFile = value;
    }
  }

  String get previewImgPath {
    return _previewImgPath!;
  }

  set previewImgPath(String value) {
    if (_previewImgPath != value) {
      _previewImgPath = value;
    }
  }

  bool get isUserModel {
    return _isUserModel!;
  }

  List<String> get linkedFiles {
    return _linkedFiles!;
  }

  set linkedFiles(List<String> value) {
    _linkedFiles = value;
  }

  static ARNodeData clone(ARNodeData data) {
    return ARNodeData.fromMap(data.toMap());
  }

  static ARNodeData fromMap(Map<String, dynamic> map) {
    return ARNodeData(
        node: ARNode.fromMap(map),
        previewName: map["preview_name"],
        previewImgPath: map["preview_path"],
        isUserModel: map["is_user_model"],
        linkedFiles: List<String>.from(map["linkedFiles"]));
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isAnimated': node.isAnimated,
        'isEnabled': node.isEnabled,
        'isPlaying': node.isPlaying,
        'volume': node.volume,
        'type': node.type.index,
        'uri': node.uri,
        'loop': node.loop,
        'chromakeyColor': node.chromakeyColor?.toHex(),
        'text': node.text,
        'width': node.width,
        'height': node.height,
        'color': node.color.toHex(),
        'light': node.light,
        'backgroundColor': node.bgColor.toHex(),
        'fontStyle': node.fontStyle.index,
        'textAlign': node.textAlign.index,
        'fontSize': node.fontSize,
        'children': node.children.map((arNode) => arNode.toMap()).toList(),
        'scale': VectorConverter().toJson(node.scale),
        'position': VectorConverter().toJson(node.position),
        'eulerAngles': VectorConverter().toJson(node.eulerAngles),
        'transformation':
            const MatrixValueNotifierConverter().toJson(node.transformNotifier),
        'name': node.id,
        'sceneName': node.name,
        'data': node.data,
        'preview_name': _previewName,
        'preview_path': _previewImgPath,
        'is_user_model': _isUserModel,
        'linkedFiles': _linkedFiles
      }..removeWhere((String k, dynamic v) => v == null);
}

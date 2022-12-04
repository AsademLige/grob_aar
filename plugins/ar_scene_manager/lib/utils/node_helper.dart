import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:flutter/material.dart';

class NodeHelper {
  static String getUniqNameByType(NodeType type) {
    switch (type) {
      case NodeType.text:
        return "#text" + UniqueKey().toString();
      case NodeType.fileSystemAppFolderVideo:
      case NodeType.localVideo:
        return "#video" + UniqueKey().toString();
      case NodeType.localAudio:
      case NodeType.fileSystemAppFolderAudio:
        return "#audio" + UniqueKey().toString();
      case NodeType.fileSystemAppFolderImage:
      case NodeType.localImage:
        return "#image" + UniqueKey().toString();
      default:
        return "#3dModel" + UniqueKey().toString();
    }
  }

  static IconData getIconByType(NodeType type) {
    switch (type) {
      case NodeType.text:
        return Icons.textsms_outlined;
      case NodeType.fileSystemAppFolderVideo:
      case NodeType.localVideo:
        return Icons.ondemand_video;
      case NodeType.localAudio:
      case NodeType.fileSystemAppFolderAudio:
        return Icons.audiotrack_outlined;
      case NodeType.fileSystemAppFolderImage:
      case NodeType.localImage:
        return Icons.image;
      default:
        return Icons.token;
    }
  }

  static getNameByType(NodeType type) {
    switch (type) {
      case NodeType.text:
        return "Текст";
      case NodeType.fileSystemAppFolderVideo:
      case NodeType.localVideo:
        return "Видео";
      case NodeType.localAudio:
      case NodeType.fileSystemAppFolderAudio:
        return "Аудио";
      case NodeType.fileSystemAppFolderImage:
      case NodeType.localImage:
        return "Изображение";
      default:
        return "3D Модель";
    }
  }
}

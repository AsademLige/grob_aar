import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_scene_manager/utils/nitifications.dart';
import 'package:ar_scene_manager/models/scene_data.dart';
import 'package:ar_scene_manager/utils/save_utils.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

class SceneLoader {
  static Future<List<List<dynamic>>> pickFiles(List<String> extensions,
      {bool allowMultiple = true}) async {
    List<PlatformFile>? files;
    List<List<dynamic>> paths = [];

    try {
      files = (await FilePicker.platform.pickFiles(
        withData: true,
        allowCompression: false,
        type: FileType.custom,
        allowMultiple: allowMultiple,
        onFileLoading: (FilePickerStatus status) => {},
        allowedExtensions: extensions,
      ))
          ?.files;
    } on PlatformException {
      Utils.toast("Ошибка при загрузке");
      return [];
    } catch (e) {
      Utils.toast("Ошибка при загрузке");
      return [];
    }

    if (files == null) return [];

    for (var pFile in files) {
      File file =
          await _saveFile(pFile.bytes!, getUniqFileName(pFile.extension!));
      if (pFile.extension == "mp4") {
        paths.add([file.path, pFile.name, NodeType.fileSystemAppFolderVideo]);
      } else if (pFile.extension == "mp3") {
        paths.add([file.path, pFile.name, NodeType.fileSystemAppFolderAudio]);
      } else if (["png", "jpeg", "jpg"].contains(pFile.extension)) {
        paths.add([file.path, pFile.name, NodeType.fileSystemAppFolderImage]);
      } else {
        if (files.length == 1) {
          Utils.toast("Неверный формат - ${pFile.extension}");
        }
      }
    }

    return paths;
  }

  static Future<List<List<dynamic>>> pickGlb() async {
    List<PlatformFile>? files;
    List<List<dynamic>> paths = [];

    try {
      files = (await FilePicker.platform.pickFiles(
        withData: true,
        allowCompression: false,
        type: FileType.any,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => {},
      ))
          ?.files;
    } on PlatformException {
      Utils.toast("Ошибка при загрузке");
      return [];
    } catch (e) {
      Utils.toast("Ошибка при загрузке");
      return [];
    }

    if (files == null) return [];

    for (var pFile in files) {
      File file =
          await _saveFile(pFile.bytes!, getUniqFileName(pFile.extension!));
      if (pFile.extension == "glb") {
        paths.add([file.path, pFile.name, NodeType.fileSystemAppFolderGLB]);
      } else {
        if (files.length == 1) {
          Utils.toast("Неверный формат - ${pFile.extension}");
        }
      }
    }

    return paths;
  }

  static Future<List<String>> pickScene() async {
    List<PlatformFile>? files;
    List<String> paths = [];

    try {
      files = (await FilePicker.platform.pickFiles(
        withData: true,
        allowCompression: false,
        type: FileType.any,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => {},
      ))
          ?.files;
    } catch (e) {
      Utils.toast("Ошибка при загрузке");
    }

    if (files == null) return [];

    for (var pFile in files) {
      if (pFile.extension == "arscene") {
        paths.add(pFile.path!);
      } else {
        await _clearCachedFiles();
        Utils.toast("Выберите файлы только с расширением .arscene!");
      }
    }

    return paths;
  }

  static Future<List<List<dynamic>>> pickGltf() async {
    List<Map<String, dynamic>> gltfTextures = [];
    List<List<dynamic>> paths = [];
    List<PlatformFile>? files;
    List<String> linkedFiles = [];

    PlatformFile? gltfFile;
    String? binName;

    try {
      files = (await FilePicker.platform.pickFiles(
              withData: true,
              allowCompression: false,
              type: FileType.any,
              allowMultiple: true,
              onFileLoading: (FilePickerStatus status) => {}))
          ?.files;
    } on PlatformException {
      Utils.toast("Ошибка при загрузке");
      return [];
    } catch (e) {
      Utils.toast("Ошибка при загрузке");
      return [];
    }

    if (files == null) return [];

    for (var pFile in files) {
      if (pFile.extension == "gltf") {
        gltfFile = pFile;
      } else if (["png", "jpeg", "jpg"].contains(pFile.extension)) {
        gltfTextures.add({"uri": getUniqFileName(pFile.extension!)});
        File file = await _saveFile(pFile.bytes!, gltfTextures.last["uri"]);
        linkedFiles.add(file.path);
      } else if (pFile.extension == "bin") {
        binName = getUniqFileName(pFile.extension!);
        File file = await _renameFile(File(pFile.path!), binName);
        linkedFiles.add(file.path);
      }
    }

    if (binName == null) {
      Utils.toast("не выбран .bin файл модели, загрузка отменена");
      for (var path in gltfTextures) {
        _deleteFile(File(path["uri"]).path);
      }

      await _clearCachedFiles();

      return [];
    }

    if (gltfFile != null) {
      File file = await _saveFile(
          gltfFile.bytes!, getUniqFileName(gltfFile.extension!));
      paths.add([file.path, gltfFile.name, linkedFiles]);
      dynamic contents = jsonDecode(await file.readAsString());

      if (contents["images"] != null &&
          (contents["images"].length != gltfTextures.length)) {
        Utils.toast("Не выбраны тектсуры модели, загрузка отменена");
        _deleteFile(file.path);
        await _clearCachedFiles();
        return [];
      }

      contents["images"] = gltfTextures;
      contents["buffers"][0]["uri"] = binName;
      await file.writeAsString(jsonEncode(contents));
    }

    await _clearCachedFiles();

    return paths;
  }

  static String getUniqFileName(String extension) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    switch (extension) {
      case "mp4":
        return "video" + timestamp.toString() + ".mp4";
      case "mp3":
        return "audio" + timestamp.toString() + ".mp3";
      case "png":
        return "image" + timestamp.toString() + ".png";
      case "jpg":
        return "image" + timestamp.toString() + ".jpg";
      case "jpeg":
        return "image" + timestamp.toString() + ".jpeg";
      case "glb":
        return "gblModel" + timestamp.toString() + ".glb";
      case "gltf":
        return "gltfModel" + timestamp.toString() + ".gltf";
      case "bin":
        return "binData" + timestamp.toString() + ".bin";
      default:
        return "file" + timestamp.toString();
    }
  }

  static Future<String> saveScene(SceneData data) async {
    String zipDir = await _localDirectory() + "/" + data.name + ".arscene";
    String sceneName = data.name + ".ardata";

    File file = await _saveFileString(data.toJson(), sceneName);

    ZipFileEncoder encoder = ZipFileEncoder();
    encoder.create(zipDir);
    encoder.addFile(file);

    for (var nodeData in data.getNodesData()) {
      if (nodeData.isUserModel) {
        File file = File(nodeData.node.uri!);
        encoder.addFile(file);
        for (var path in nodeData.linkedFiles) {
          File linkedFile =
              File(await _localDirectory() + "/" + path.split("/").last);
          encoder.addFile(linkedFile);
        }
      }
    }

    encoder.close();

    return zipDir;
  }

  static Future<SceneData?> loadScene(String path,
      {bool fromFlutterAssets = false}) async {
    SceneData? sceneData;
    List<File> files = [];

    Uint8List? bytes;

    try {
      if (fromFlutterAssets) {
        ByteData byteData = await rootBundle.load(path);
        bytes = byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      } else {
        bytes = File("${await _localDirectory()}/${path.split("/").last}")
            .readAsBytesSync();
      }

      final Archive archive = ZipDecoder().decodeBytes(bytes);

      for (final afile in archive) {
        File file = await _saveFile(afile.content, afile.name);
        files.add(file);
        String extension = p.extension(file.path);
        if (extension == ".ardata") {
          sceneData = await SceneData.fromUri(file.path);
        }
      }

      if (sceneData != null) {
        for (var nodeData in sceneData.getNodesData()) {
          if (nodeData.isUserModel) {
            nodeData.node.uri = files
                .singleWhere((file) =>
                    file.uri.pathSegments.last ==
                    nodeData.node.uri!.split("/").last)
                .path;
            if (!await SavedPrefs.checkModelByPath(nodeData.node.uri!)) {
              SavedPrefs.saveModel(nodeData.toMap());
            }
          }
        }
      }

      await _clearCachedFiles();
    } catch (_) {}
    return sceneData;
  }

  static Future<List<ARNode>> loadNodes(String path,
      {bool fromFlutterAssets = false}) async {
    SceneData? sceneData =
        await loadScene(path, fromFlutterAssets: fromFlutterAssets);

    if (sceneData != null) {
      return sceneData.getSceneNodesList();
    } else {
      return [];
    }
  }

  static Future<void> shareFile(String path) async {
    File file = File(path);
    if (!file.existsSync()) return;
    return await Share.shareFiles([file.path], text: '');
  }

  static garbageCollector() async {
    final filesList = Directory(await _localDirectory()).listSync();

    List<dynamic> savedModels = await SavedPrefs.getModels();
    List<dynamic> savedScenes = await SavedPrefs.getScenes();

    for (var file in filesList) {
      bool exist = false;
      for (var node in savedModels) {
        if (node["uri"] == file.path ||
            List<String>.from(node["linkedFiles"]).contains(file.path) ||
            node["preview_path"] == file.path) {
          exist = true;
        }
      }

      for (var scene in savedScenes) {
        if (scene["path"] == file.path) exist = true;
      }
      if (!exist) {
        _deleteFile(file.path);
      }
    }
  }

  static Future<bool> _deleteFile(String path) async {
    try {
      File file = File(path);
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<File> _renameFile(File oldFile, String fileName) async {
    String appDocumentsPath = await _localDirectory();
    String filePath = '$appDocumentsPath/$fileName';

    return await oldFile.rename(filePath);
  }

  static Future<File> _saveFile(Uint8List data, String fileName) async {
    String appDocumentsPath = await _localDirectory();
    String filePath = '$appDocumentsPath/$fileName';

    File file = File(filePath);

    return await file.writeAsBytes(data);
  }

  static Future<File> _saveFileString(String data, String fileName) async {
    String appDocumentsPath = await _localDirectory();
    String filePath = '$appDocumentsPath/$fileName';

    File file = File(filePath);

    return await file.writeAsString(data);
  }

  static Future<String> _localDirectory() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return appDocumentsDirectory.path;
  }

  static Future<bool?> _clearCachedFiles() async {
    try {
      return await FilePicker.platform.clearTemporaryFiles();
    } catch (e) {
      return false;
    }
  }
}

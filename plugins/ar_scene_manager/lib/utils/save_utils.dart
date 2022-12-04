import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedPrefs {
  static const String modelsKey = "models";
  static const String scenesKey = "scenes";

  static Future<bool> saveScene(Map<String, dynamic> sceneData) async {
    try {
      List<dynamic> savedScenes = await getScenes();
      savedScenes.removeWhere(
          (oldSceneName) => oldSceneName["name"] == sceneData["name"]);
      savedScenes.add(sceneData);
      String json = jsonEncode(savedScenes);
      return _saveString(scenesKey, json);
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getScenes() async {
    if (await checkOption(scenesKey)) {
      try {
        return await jsonDecode(await _getString(scenesKey));
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<dynamic> getSceneByName(String name) async {
    try {
      List<dynamic> savedScenes = await getScenes();
      return savedScenes.singleWhere((data) => data["name"] == name);
    } catch (e) {
      return null;
    }
  }

  static Future<String> getScenePathByName(String path) async {
    try {
      List<dynamic> savedScenes = await getScenes();
      dynamic data = savedScenes.singleWhere((data) => data["path"] == path);
      return data["path"];
    } catch (e) {
      return "";
    }
  }

  static Future<int> getSavedSceneCount() async {
    List<dynamic> savedScenePaths = await getScenes();
    return savedScenePaths.length;
  }

  static Future<bool> removeSceneByName(String name) async {
    try {
      List<dynamic> savedScenes = await getScenes();
      savedScenes.removeWhere((oldSceneName) => oldSceneName["name"] == name);
      String json = jsonEncode(savedScenes);
      return _saveString(scenesKey, json);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveModel(Map<String, dynamic> model) async {
    try {
      List<dynamic> savedModels = await getModels();
      savedModels.removeWhere((oldModel) => oldModel["name"] == model["name"]);
      savedModels.add(model);
      String json = jsonEncode(savedModels);
      return _saveString(modelsKey, json);
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getModels() async {
    if (await checkOption(modelsKey)) {
      try {
        List<dynamic> modelsData =
            await jsonDecode(await _getString(modelsKey));
        return modelsData;
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<bool> checkModelByPath(String path) async {
    try {
      List<dynamic> savedModels = await getModels();
      savedModels.singleWhere((data) => data["node"]["path"] == path);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeModelByName(String name) async {
    try {
      List<dynamic> savedModels = await getModels();
      savedModels.removeWhere((oldModel) => oldModel["name"] == name);
      String json = jsonEncode(savedModels);
      return _saveString(modelsKey, json);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkOption(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  static Future<bool> removeAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  static Future<bool> _saveString(String key, String option) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, option);
  }

  static Future<String> _getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "[]";
  }
}

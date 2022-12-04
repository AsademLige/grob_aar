import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

enum TtsState { playing, stopped, paused, continued }

class VoiceSettingsController extends GetxController {
  FlutterTts? flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  List<Map<String, String>> voices = [];
  String? voiceText = "";
  int? inputLength = 3000;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  @override
  void onInit() {
    super.onInit();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    _initVoices();

    if (Platform.isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts!.setStartHandler(() {
      print("Playing");
      ttsState = TtsState.playing;
      update();
    });

    if (Platform.isAndroid) {
      flutterTts!.setInitHandler(() {
        print("TTS Initialized");
        update();
      });
    }

    flutterTts!.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
      update();
    });

    flutterTts!.setCancelHandler(() {
      print("Cancel");
      ttsState = TtsState.stopped;
      update();
    });

    flutterTts!.setPauseHandler(() {
      print("Paused");
      ttsState = TtsState.paused;
      update();
    });

    flutterTts!.setContinueHandler(() {
      print("Continued");
      ttsState = TtsState.continued;
      update();
    });

    flutterTts!.setErrorHandler((msg) {
      print("error: $msg");
      ttsState = TtsState.stopped;
      update();
    });
  }

  _initVoices() async {
    final _voices = await flutterTts!.getVoices;

    for (var voice in _voices) {
      if (voice["locale"] == "ru-RU") {
        voices.add({"name": voice["name"], "locale": voice["locale"]});
      }
    }
    update();
  }

  setVoice(Map<String, String> voice) {
    print(voice);
    flutterTts!.setVoice(voice);
  }

  Future _setAwaitOptions() async {
    await flutterTts!.awaitSpeakCompletion(true);
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts!.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts!.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<dynamic> getLanguages() async => await flutterTts!.getLanguages;

  Future<dynamic> getEngines() async => await flutterTts!.getEngines;

  Future speak() async {
    await flutterTts!.setVolume(volume);
    await flutterTts!.setSpeechRate(rate);
    await flutterTts!.setPitch(pitch);

    if (voiceText!.isNotEmpty) {
      await flutterTts!.speak(voiceText!);
    } else {
      Get.showSnackbar(const GetSnackBar(
        duration: Duration(seconds: 3),
        messageText: Text("Напиши хотя бы слово!"),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      ));
    }
  }

  Future stop() async {
    var result = await flutterTts!.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
      update();
    }
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(value: type as String, child: Text(type)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) async {
    await flutterTts!.setEngine(selectedEngine!);
    language = "";
    engine = selectedEngine;
    update();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(value: type as String, child: Text(type)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    language = selectedType;
    flutterTts!.setLanguage(language!);
    if (Platform.isAndroid) {
      flutterTts!
          .isLanguageInstalled(language!)
          .then((value) => isCurrentLanguageInstalled = (value as bool));
    }
    update();
  }

  void onChange(String text) {
    voiceText = text;
    update();
  }
}

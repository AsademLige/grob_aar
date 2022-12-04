import 'package:ar_scene_manager/widgets/scene_menu/scene_settings.dart';
import 'package:ar_scene_manager/controllers/scene_menu_controller.dart';
import 'package:ar_scene_manager/widgets/scene_menu/nodes_tree.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_scene_manager/classes/scene_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SceneMenu extends GetView<SceneMenuController> {
  final ARSessionManager arSessionManager;
  final ARObjectManager arObjectManager;
  final SceneManager sceneManager;

  SceneMenu(
      {Key? key,
      required this.arSessionManager,
      required this.arObjectManager,
      required this.sceneManager})
      : super(key: key) {
    controller.sceneManager = sceneManager;
    controller.arObjectManager = arObjectManager;
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          appBar: PreferredSize(
            preferredSize: const TabBar(tabs: []).preferredSize,
            child: Container(
                decoration: const BoxDecoration(
                    color: Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    )),
                child: const TabBar(
                    labelColor: Color(0xFF555555),
                    indicatorColor: Color(0xFF555555),
                    unselectedLabelColor: Color(0xFF555555),
                    tabs: <Tab>[
                      Tab(text: 'Создать'),
                      Tab(text: 'На сцене'),
                      Tab(text: 'Настройки'),
                    ])),
          ),
          body: TabBarView(
            children: [
              Stack(
                children: [
                  GetBuilder(
                    init: controller,
                    builder: (_) {
                      return GridView.count(
                        padding: const EdgeInsets.all(8),
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        children: [...controller.models],
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    alignment: Alignment.bottomRight,
                    child: PopupMenuButton(
                        padding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: const Icon(Icons.upload_file),
                        ),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              onTap: () => controller.loadImages(),
                              child: Row(children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: const Icon(
                                    Icons.image,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const Text(
                                  '.png, .jpg',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333)),
                                )
                              ]),
                            ),
                            PopupMenuItem(
                              onTap: () => controller.loadAudio(),
                              child: Row(children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: const Icon(
                                    Icons.audiotrack_outlined,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const Text(
                                  '.mp3',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333)),
                                )
                              ]),
                            ),
                            PopupMenuItem(
                              onTap: () => controller.loadVideo(),
                              child: Row(children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: const Icon(
                                    Icons.ondemand_video,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const Text(
                                  '.mp4',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333)),
                                )
                              ]),
                            ),
                            PopupMenuItem(
                              onTap: () => controller.loadGbl(),
                              child: Row(children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: const Icon(
                                    Icons.token,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const Text(
                                  '.glb',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333)),
                                )
                              ]),
                            ),
                            PopupMenuItem(
                              onTap: () => controller.loadGltf(),
                              child: Row(children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: const Icon(
                                    Icons.token,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const Text(
                                  '.gltf',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333)),
                                )
                              ]),
                            ),
                          ];
                        }),
                  ),
                  Container(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).size.width / 2,
                      margin: const EdgeInsets.all(4),
                      child: TextField(
                        autofocus: false,
                        textInputAction: TextInputAction.send,
                        autocorrect: false,
                        style: const TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                          filled: true,
                          fillColor: const Color(0xFFEEEEEE).withAlpha(240),
                          labelText: "Поиск модели...",
                          labelStyle: const TextStyle(color: Color(0xFF333333)),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          suffixIcon: const Icon(Icons.search),
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0)),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0)),
                        ),
                        onTap: () {
                          controller.filter = "";
                        },
                        onChanged: (String name) {
                          controller.filter = name;
                        },
                      )),
                ],
              ),
              NodesTree(
                sceneManager: sceneManager,
                controller: controller,
                arObjectManager: arObjectManager,
              ),
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child:
                        SceneSettings(sceneData: sceneManager.getSceneData()),
                  ),
                  Container(
                      margin: const EdgeInsets.all(16),
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                            child: FloatingActionButton(
                              onPressed: () async => controller.saveScene(),
                              child: const Icon(Icons.save),
                              backgroundColor: const Color(0xFFFFFFFF),
                              foregroundColor: const Color(0xFF555555),
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: () async => controller.shareScene(),
                            child: const Icon(Icons.share),
                            backgroundColor: const Color(0xFFFFFFFF),
                            foregroundColor: const Color(0xFF555555),
                          )
                        ],
                      )),
                ],
              )
            ],
          ),
        ));
  }
}

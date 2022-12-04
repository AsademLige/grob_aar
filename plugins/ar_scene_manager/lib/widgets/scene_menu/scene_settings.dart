import 'package:ar_scene_manager/models/scene_data.dart';
import 'package:flutter/material.dart';

class SceneSettings extends StatelessWidget {
  final SceneData sceneData;
  const SceneSettings({Key? key, required this.sceneData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 0, 8),
          child: Row(
            children: [
              Flexible(
                  child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                height: 40,
                child: TextField(
                    autofocus: false,
                    textInputAction: TextInputAction.send,
                    autocorrect: false,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(9, 0, 8, 0),
                        filled: true,
                        fillColor: const Color(0xFFEEEEEE),
                        labelText: sceneData.name,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide:
                                BorderSide(color: Color(0xFFEEEEEE), width: 1)),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1)),
                        suffixIcon: IconButton(
                          color: const Color(0xFF555555),
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                        )),
                    onChanged: (String name) {
                      sceneData.name = name;
                    }),
              )),
            ],
          ),
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ))
      ],
    );
  }
}

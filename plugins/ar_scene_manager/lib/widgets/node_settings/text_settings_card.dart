import 'package:ar_flutter_plugin/datatypes/text_node_font_style.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/datatypes/text_node_align.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextSettings extends StatelessWidget {
  TextSettings(
      {Key? key,
      required this.arNode,
      required this.arObjectManager,
      required this.rxColor,
      required this.rxBgClor})
      : super(key: key);

  final ARObjectManager arObjectManager;
  final ARNode arNode;
  final Rx<Color> rxColor;
  final Rx<Color> rxBgClor;

  final List<int> fontSizes = [
    12,
    14,
    16,
    18,
    20,
    22,
    24,
    28,
    32,
    36,
    40,
    48,
    60
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                    Flexible(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Цвет текста'),
                                              content: SingleChildScrollView(
                                                child: ColorPicker(
                                                  pickerColor: arNode.color,
                                                  onColorChanged:
                                                      (Color color) {
                                                    rxColor.value = color;
                                                    arObjectManager
                                                        .getNodeById(arNode.id)!
                                                        .color = color;
                                                  },
                                                ),
                                              ),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  child: const Text('Выбрать'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 5, 8, 5),
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  8, 0, 8, 0),
                                              child: const Icon(Icons
                                                  .format_color_text_rounded),
                                            ),
                                            Obx(() => Container(
                                                  decoration: BoxDecoration(
                                                      color: rxColor.value,
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFFEEEEEE)),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  8))),
                                                  height: 25,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 25),
                                                )),
                                          ]),
                                    )),
                                GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Цвет фона'),
                                              content: SingleChildScrollView(
                                                child: ColorPicker(
                                                  pickerColor: arNode.bgColor,
                                                  onColorChanged:
                                                      (Color bgColor) {
                                                    rxBgClor.value = bgColor;
                                                    arObjectManager
                                                        .getNodeById(arNode.id)!
                                                        .bgColor = bgColor;
                                                  },
                                                ),
                                              ),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  child: const Text('Выбрать'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 5, 8, 5),
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  8, 0, 8, 0),
                                              child: const Icon(Icons
                                                  .format_color_fill_rounded),
                                            ),
                                            Obx((() => Container(
                                                decoration: BoxDecoration(
                                                    color: rxBgClor.value,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                height: 25,
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 25)))),
                                          ]),
                                    )),
                                PopupMenuButton(
                                    padding: const EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: const Icon(
                                          Icons.font_download_outlined),
                                    ),
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          onTap: () => arNode.fontStyle =
                                              NodeFontStyle.bold,
                                          child: const Text(
                                            'Bold',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF333333)),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () => arNode.fontStyle =
                                              NodeFontStyle.boldItalic,
                                          child: const Text(
                                            'Bold Italic',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF333333)),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () => arNode.fontStyle =
                                              NodeFontStyle.italic,
                                          child: const Text(
                                            'italic',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF333333)),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () => arNode.fontStyle =
                                              NodeFontStyle.normal,
                                          child: const Text(
                                            'Normal',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF333333)),
                                          ),
                                        )
                                      ];
                                    }),
                                PopupMenuButton(
                                    padding: const EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child:
                                          const Icon(Icons.format_size_rounded),
                                    ),
                                    itemBuilder: (context) {
                                      return fontSizes
                                          .map((fontSize) => PopupMenuItem(
                                                onTap: () =>
                                                    arNode.fontSize = fontSize,
                                                child: Text(
                                                  fontSize.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF333333)),
                                                ),
                                              ))
                                          .toList();
                                    }),
                                PopupMenuButton(
                                    padding: const EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))),
                                      child: const Icon(Icons.notes_rounded),
                                    ),
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          onTap: () => arNode.textAlign =
                                              NodeTextAlign.left,
                                          child: const Text(
                                            'По левому',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF333333)),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () => arNode.textAlign =
                                              NodeTextAlign.center,
                                          child: const Text(
                                            'По центру',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF333333)),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () => arNode.textAlign =
                                              NodeTextAlign.right,
                                          child: const Text(
                                            'По правому',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF333333)),
                                          ),
                                        ),
                                      ];
                                    }),
                              ],
                            ),
                          ),
                          Expanded(
                              child: TextField(
                                  expands: true,
                                  maxLines: null,
                                  autofocus: false,
                                  textInputAction: TextInputAction.send,
                                  textAlignVertical: TextAlignVertical.top,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.fromLTRB(9, 8, 8, 0),
                                      filled: true,
                                      fillColor: const Color(0xFFFFFFFF),
                                      labelText: arNode.text,
                                      alignLabelWithHint: true,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          borderSide: BorderSide(
                                              color: Color(0xFFEEEEEE),
                                              width: 1)),
                                      focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1)),
                                      suffixIcon: const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          widthFactor: 1.0,
                                          heightFactor: 10.0,
                                          child: Icon(
                                            Icons.edit,
                                          ),
                                        ),
                                      )),
                                  onChanged: (String text) {
                                    arNode.text = text;
                                  })),
                        ]))
                  ])))
            ]));
  }
}

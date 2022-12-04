import 'package:ar_scene_manager/models/arnode_data.dart';
import 'package:ar_scene_manager/utils/node_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class NodeCard extends StatelessWidget {
  final ARNodeData nodeData;
  final void Function() onTap;
  final void Function() onDelete;
  final void Function() onPickImage;
  final void Function(String) onRename;

  const NodeCard(
      {Key? key,
      required this.nodeData,
      required this.onTap,
      required this.onDelete,
      required this.onPickImage,
      required this.onRename})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: Color(0xFFDDDDDD),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Stack(fit: StackFit.expand, children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: FittedBox(
              child: (nodeData.previewImgPath != "" &&
                      File(nodeData.previewImgPath).existsSync())
                  ? (nodeData.isUserModel)
                      ? Image.file(File(nodeData.previewImgPath))
                      : Image.asset(nodeData.previewImgPath)
                  : Icon(
                      NodeHelper.getIconByType(nodeData.node.type),
                      color: const Color(0xFF555555),
                    ),
              fit: (!nodeData.isUserModel) ? BoxFit.fitHeight : BoxFit.contain,
            ),
          ),
          Container(
            margin: (nodeData.isUserModel)
                ? const EdgeInsets.fromLTRB(0, 0, 30, 0)
                : const EdgeInsets.all(0),
            alignment: Alignment.topLeft,
            child: Container(
                padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(185, 238, 238, 238),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      NodeHelper.getIconByType(nodeData.node.type),
                      color: const Color(0xFF333333),
                    ),
                  ),
                  Flexible(
                      child: Text(
                    NodeHelper.getNameByType(nodeData.node.type),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontSize: 14),
                  )),
                ])),
          ),
          Container(
              alignment: Alignment.bottomCenter,
              child: (nodeData.isUserModel)
                  ? TextField(
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
                        fillColor: const Color.fromARGB(185, 238, 238, 238),
                        labelText: nodeData.previewName,
                        labelStyle: const TextStyle(color: Color(0xFF333333)),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0)),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0)),
                      ),
                      onSubmitted: onRename,
                    )
                  : Container(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(185, 238, 238, 238),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  nodeData.previewName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                      fontSize: 14),
                                ),
                              ])),
                    )),
          Visibility(
              visible: (nodeData.isUserModel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(185, 238, 238, 238),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onPickImage,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(185, 238, 238, 238),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF555555),
                      ),
                    ),
                  )
                ],
              ))
        ]),
      ),
    );
  }
}

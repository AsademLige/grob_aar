import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParamsCard extends StatelessWidget {
  const ParamsCard({
    Key? key,
    required this.arNode,
    required this.arObjectManager,
    required this.dpdValue,
    required this.onDpdValueChange,
    required this.onVolumeUpdate,
    required this.onSetPlaying,
    required this.volume,
    required this.isPlaying,
    required this.isAnimated,
  }) : super(key: key);

  final ARObjectManager arObjectManager;
  final ARNode arNode;
  final RxString dpdValue;
  final RxInt volume;
  final RxBool isPlaying;
  final RxBool isAnimated;
  final Function(String?) onDpdValueChange;
  final Function(DragUpdateDetails)? onVolumeUpdate;
  final Function()? onSetPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        child: Column(
          children: [
            Visibility(
                visible: (arNode.isMedia()),
                child: GestureDetector(
                  onPanUpdate: onVolumeUpdate,
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Row(children: [
                        GestureDetector(
                          onTap: onSetPlaying,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color(0xFFDDDDDD),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            padding: const EdgeInsets.all(16),
                            child: Obx(() => Icon(
                                  (isPlaying.value)
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: const Color(0xFF555555),
                                )),
                          ),
                        ),
                        const Icon(
                          Icons.volume_down_outlined,
                          color: Color(0xFF777777),
                        ),
                        Expanded(
                            child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Color(0xFFDDDDDD),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          child: Obx(() => Text(
                                "$volume %",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              )),
                        )),
                        const Icon(
                          Icons.volume_up_outlined,
                          color: Color(0xFF777777),
                        ),
                      ])),
                )),
            Visibility(
                visible: !arNode.isAudio(),
                child: Flexible(
                    child: Container(
                  height: 40,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Obx(() => DropdownButton<String>(
                          iconSize: 20,
                          isExpanded: true,
                          value: dpdValue.value,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Color(0xFF333333)),
                          underline: Container(
                            height: 2,
                            color: const Color(0xFFDDDDDD),
                          ),
                          onChanged: onDpdValueChange,
                          items: [
                            ...arObjectManager
                                .getNodes()
                                .map((index, cNode) => MapEntry(
                                    index,
                                    DropdownMenuItem<String>(
                                      value: cNode.id,
                                      child: Text(
                                        (arNode.id == cNode.id)
                                            ? "Сцена"
                                            : (cNode.name != "")
                                                ? cNode.name
                                                : cNode.id,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )))
                                .values
                                .toList()
                          ])),
                ))),
            Visibility(
                visible: false,
                child: Obx(() => Switch(
                      value: isAnimated.value,
                      onChanged: (value) {
                        arNode.isAnimated = !arNode.isAnimated;
                        isAnimated.value = !isAnimated.value;
                      },
                      activeTrackColor: const Color(0xFFDDDDDD),
                      activeColor: const Color(0xFF555555),
                    ))),
          ],
        ));
  }
}

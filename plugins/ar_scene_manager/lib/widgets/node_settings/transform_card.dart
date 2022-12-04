import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransformCard extends StatelessWidget {
  const TransformCard(
      {Key? key,
      required this.cardIcon,
      this.onUpdateX,
      this.onUpdateY,
      this.onUpdateZ,
      this.onLeftXTap,
      this.onLeftYTap,
      this.onLeftZTap,
      this.onRightXTap,
      this.onRightYTap,
      this.onRightZTap,
      this.onLinkToggle,
      this.linkToggleValue,
      this.rxValue,
      this.ryValue,
      this.rzValue,
      this.xSuffix = "X :",
      this.ySuffix = "Y :",
      this.zSuffix = "Z :",
      this.digitsCount = 2,
      this.alignment = CrossAxisAlignment.stretch})
      : super(key: key);

  final IconData cardIcon;

  final Function(DragUpdateDetails)? onUpdateX;
  final Function(DragUpdateDetails)? onUpdateY;
  final Function(DragUpdateDetails)? onUpdateZ;
  final Function()? onLeftXTap;
  final Function()? onLeftYTap;
  final Function()? onLeftZTap;
  final Function()? onRightXTap;
  final Function()? onRightYTap;
  final Function()? onRightZTap;
  final Function()? onLinkToggle;

  final RxDouble? rxValue;
  final RxDouble? ryValue;
  final RxDouble? rzValue;

  final RxBool? linkToggleValue;

  final String xSuffix;
  final String ySuffix;
  final String zSuffix;

  final int digitsCount;

  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
          crossAxisAlignment: alignment,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Icon(
                        cardIcon,
                        color: const Color(0xFF555555),
                        size: 35,
                      ),
                    ),
                    Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Visibility(
                            visible: (rxValue != null) ? true : false,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: onLeftXTap,
                                  child: Container(
                                    height: 30,
                                    margin:
                                        const EdgeInsets.fromLTRB(8, 8, 0, 0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFd3d3d3),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xFFd3d3d3),
                                            style: BorderStyle.solid)),
                                    child: const Icon(Icons.arrow_left),
                                  ),
                                ),
                                Expanded(
                                    child: GestureDetector(
                                  onPanUpdate: onUpdateX,
                                  child: Container(
                                    height: 30,
                                    alignment: Alignment.center,
                                    color: const Color(0xFFDDDDDD),
                                    padding: const EdgeInsets.all(8),
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Obx(() => Text(
                                          "$xSuffix ${rxValue?.value.toStringAsFixed(digitsCount) ?? 0.0}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ),
                                )),
                                GestureDetector(
                                  onTap: onRightXTap,
                                  child: Container(
                                    height: 30,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 8, 0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFd3d3d3),
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8)),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xFFd3d3d3),
                                            style: BorderStyle.solid)),
                                    child: const Icon(Icons.arrow_right),
                                  ),
                                ),
                              ],
                            )),
                        Visibility(
                            visible: (ryValue != null) ? true : false,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: onLeftYTap,
                                  child: Container(
                                    height: 30,
                                    margin:
                                        const EdgeInsets.fromLTRB(8, 8, 0, 0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFd3d3d3),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xFFd3d3d3),
                                            style: BorderStyle.solid)),
                                    child: const Icon(Icons.arrow_left),
                                  ),
                                ),
                                Expanded(
                                    child: GestureDetector(
                                  onPanUpdate: onUpdateY,
                                  child: Container(
                                    height: 30,
                                    alignment: Alignment.center,
                                    color: const Color(0xFFDDDDDD),
                                    padding: const EdgeInsets.all(8),
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Obx(() => Text(
                                          "$ySuffix ${ryValue?.value.toStringAsFixed(digitsCount) ?? 0.0}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ),
                                )),
                                GestureDetector(
                                  onTap: onRightYTap,
                                  child: Container(
                                    height: 30,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 8, 0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFd3d3d3),
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8)),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xFFd3d3d3),
                                            style: BorderStyle.solid)),
                                    child: const Icon(Icons.arrow_right),
                                  ),
                                ),
                              ],
                            )),
                        Visibility(
                            visible: (rzValue != null) ? true : false,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: onLeftZTap,
                                  child: Container(
                                    height: 30,
                                    margin:
                                        const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFd3d3d3),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xFFd3d3d3),
                                            style: BorderStyle.solid)),
                                    child: const Icon(Icons.arrow_left),
                                  ),
                                ),
                                Expanded(
                                    child: GestureDetector(
                                  onPanUpdate: onUpdateZ,
                                  child: Container(
                                    height: 30,
                                    alignment: Alignment.center,
                                    color: const Color(0xFFDDDDDD),
                                    padding: const EdgeInsets.all(8),
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    child: Obx(() => Text(
                                          "$zSuffix ${rzValue?.value.toStringAsFixed(digitsCount) ?? 0.0}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )),
                                  ),
                                )),
                                GestureDetector(
                                  onTap: onRightZTap,
                                  child: Container(
                                    height: 30,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFd3d3d3),
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8)),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xFFd3d3d3),
                                            style: BorderStyle.solid)),
                                    child: const Icon(Icons.arrow_right),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )),
                    Visibility(
                        visible: (linkToggleValue != null) ? true : false,
                        child: GestureDetector(
                          onTap: onLinkToggle,
                          child: Obx(() => Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: (linkToggleValue != null &&
                                              linkToggleValue!.value)
                                          ? const Color(0xFFDDDDDD)
                                          : const Color(0xFFDDDDDD)
                                              .withAlpha(100),
                                    ),
                                    color: (linkToggleValue != null &&
                                            linkToggleValue!.value)
                                        ? const Color(0xFFDDDDDD)
                                        : const Color(0xFFDDDDDD)
                                            .withAlpha(100),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                padding: const EdgeInsets.all(2),
                                child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Icon(
                                      Icons.link,
                                      color: (linkToggleValue != null &&
                                              linkToggleValue!.value)
                                          ? const Color(0xFF555555)
                                          : const Color(0xFF555555)
                                              .withAlpha(100),
                                    )),
                              )),
                        ))
                  ]),
            )),
          ]),
    );
  }
}

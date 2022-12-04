import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grob_aar/themes/color_alias.dart';

class StaticticCard extends StatelessWidget {
  final EdgeInsets margin;

  const StaticticCard({
    Key? key,
    this.margin = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: 114,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          border: Border.all(
            color: Get.theme.primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SvgPicture.asset(
              "assets/icons/showel.svg",
              fit: BoxFit.cover,
              width: 180,
              height: 180,
              color: ColorAlias.textPrimary.withAlpha(50),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                child: const Text("Уже похоронено",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    )),
              ),
              Row(
                children: [
                  Container(
                    child: SvgPicture.asset(
                      "assets/icons/skull.svg",
                      color: ColorAlias.textPrimary,
                    ),
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    width: 40,
                    height: 40,
                  ),
                  const Text("36",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 36)),
                ],
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Text("Только им не говорите",
                    style: TextStyle(
                      color: ColorAlias.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

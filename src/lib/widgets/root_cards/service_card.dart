import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grob_aar/themes/color_alias.dart';

class ServiceCard extends StatelessWidget {
  final EdgeInsets margin;
  final String title;
  final String subTitle;
  final Widget icon;
  final Function onTap;

  const ServiceCard({
    Key? key,
    required this.icon,
    this.title = "",
    this.subTitle = "",
    required this.onTap,
    this.margin = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              child: icon,
              width: 80,
              height: 80,
            ),
            decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                border: Border.all(
                  color: Get.theme.primaryColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
          ),
          Expanded(
            child: Container(
              height: 96,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 20)),
                  Text(subTitle,
                      style: TextStyle(
                          color: ColorAlias.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12))
                ],
              ),
              decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  border: Border.all(
                    color: Get.theme.primaryColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
            ),
          ),
          Container(
            height: 96,
            width: 50,
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
                onPressed: () => onTap(),
                child: const Icon(Icons.arrow_forward_ios_rounded)),
          )
        ],
      ),
    );
  }
}

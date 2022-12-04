import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grob_aar/themes/color_alias.dart';

class QuotesCard extends StatelessWidget {
  final EdgeInsets margin;
  const QuotesCard({
    Key? key,
    this.margin = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              height: 96,
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                border: Border.all(
                  color: Get.theme.primaryColor,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Transform.rotate(
                      angle: -0.45,
                      child: SvgPicture.asset(
                        "assets/icons/book.svg",
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        color: ColorAlias.textPrimary.withAlpha(50),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(left: 100),
                    child: Text(
                      "« — Боюсь, он умер.\n"
                      "— Доктор, я не умер!\n"
                      "— Извините, но боюсь, \nчто доктор здесь я.»",
                      style: TextStyle(
                        color: ColorAlias.textPrimary.withAlpha(100),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
              height: 96,
              width: 50,
              margin: const EdgeInsets.only(left: 8),
              child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorAlias.primaryDark)),
                  child: const Icon(Icons.share)))
        ],
      ),
    );
  }
}

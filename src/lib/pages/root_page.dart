import 'package:flutter_svg/svg.dart';
import 'package:grob_aar/get/controllers/root_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grob_aar/get/pages.dart';
import 'package:grob_aar/themes/color_alias.dart';
import 'package:grob_aar/widgets/root_cards/quotes_card.dart';
import 'package:grob_aar/widgets/root_cards/service_card.dart';
import 'package:grob_aar/widgets/root_cards/statistic_card.dart';

class RootPage extends GetView<RootController> {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              alignment: Alignment.center,
              child: const Text(
                "Я.Гробанулся",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            const StaticticCard(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
            ),
            const QuotesCard(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
            ),
            ServiceCard(
              title: "Похоронить",
              subTitle: "Реальный результат не гарантирован",
              icon: SvgPicture.asset("assets/icons/coffin.svg",
                  color: ColorAlias.textPrimary),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              onTap: () => Get.toNamed(Routes.SETTINGS),
            ),
            ServiceCard(
              title: "Посетить могилу",
              subTitle: "Не нужно оповещать усопшего о визите",
              icon: SvgPicture.asset(
                "assets/icons/grave.svg",
                color: ColorAlias.textPrimary,
              ),
              margin: const EdgeInsets.all(16),
              onTap: () => Get.showSnackbar(const GetSnackBar(
                duration: Duration(seconds: 3),
                messageText: Text(
                    "Прийти на могилу усопшего можно будут в следующих обновлениях!"),
                margin: EdgeInsets.all(16),
                borderRadius: 8,
              )),
            ),
          ],
        ),
      ),
    );
  }
}

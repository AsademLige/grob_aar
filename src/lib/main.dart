import 'package:flutter/material.dart';
import 'package:grob_aar/themes/theme_dark.dart';
import 'package:get/get.dart';
import 'package:grob_aar/themes/theme_light.dart';
import 'get/bindings.dart';
import 'get/pages.dart';

void main() {
  runApp(
    GetMaterialApp(
        getPages: AppPages.pages,
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        locale: Get.locale,
        initialBinding: Binding(),
        themeMode: ThemeMode.dark,
        initialRoute: Routes.MAIN),
  );
}

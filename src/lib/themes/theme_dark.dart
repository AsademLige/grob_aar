import 'package:grob_aar/themes/color_alias.dart';
import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: ColorAlias.primaryDark,
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(ColorAlias.buttonPrimary),
  )),
  scaffoldBackgroundColor: ColorAlias.backgroundDark,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    alignLabelWithHint: true,
    fillColor: ColorAlias.backgroundDark.withAlpha(100),
    labelStyle: const TextStyle(
      color: Colors.blue,
    ),
    hintStyle: TextStyle(
      color: ColorAlias.textPrimary.withAlpha(100),
      fontStyle: FontStyle.italic,
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(
        style: BorderStyle.solid,
        color: Colors.blue,
      ),
    ),
  ),
);

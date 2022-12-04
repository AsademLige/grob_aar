import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Utils {
  static toast(String text) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: Text(text),
        action: SnackBarAction(
            textColor: Colors.white,
            label: 'Закрыть',
            onPressed:
                ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar)));
  }

  static richToast(
    List<TextSpan> textList, {
    TextStyle style = const TextStyle(
      color: Colors.white,
      fontSize: 14,
    ),
  }) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: RichText(
            text: TextSpan(
          style: style,
          children: [...textList],
        )),
        action: SnackBarAction(
            textColor: Colors.white,
            label: 'Закрыть',
            onPressed:
                ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar)));
  }

  static Future<bool?> confirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: Get.context!,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }
}

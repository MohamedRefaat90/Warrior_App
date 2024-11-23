import 'package:Warrior/core/constants/colors.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

flushBar(
    {required BuildContext context,
    String? message,
    FlushbarPosition? position,
    EdgeInsets? margin,
    Widget? textMessage}) {
  Flushbar(
          flushbarPosition: position ?? FlushbarPosition.BOTTOM,
          margin: EdgeInsets.zero,
          icon: const Icon(Icons.info_outline, color: Color(0xFFF56242)),
          backgroundColor: AppColors.black,
          messageText: textMessage,
          message: message,
          messageSize: 16,
          messageColor: Colors.white,
          duration: const Duration(seconds: 4))
      .show(context);
}

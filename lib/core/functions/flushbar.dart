import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

// void flushBar(BuildContext context,
//     {String? message,
//     FlushbarPosition? position,
//     EdgeInsets? margin,
//     Color color = AppColors.black,
//     Widget? textMessage}) {
//   Flushbar(
//           flushbarPosition: position ?? FlushbarPosition.BOTTOM,
//           margin: margin ?? EdgeInsets.zero,
//           icon: const Icon(Icons.info_outline,
//               color: Color.fromARGB(255, 227, 245, 66)),
//           backgroundColor: color,
//           messageText: textMessage,
//           message: message,
//           messageSize: 16,
//           messageColor: Colors.white,
//           duration: const Duration(seconds: 4))
//       .show(context);
// }

/// Show error flushbar
void showErrorFlushbar(BuildContext context, String message,
    {FlushbarPosition position = FlushbarPosition.TOP}) {
  Flushbar(
    flushbarPosition: position,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(12),
    icon: const Icon(
      Icons.error_outline,
      color: Colors.white,
      size: 28,
    ),
    backgroundColor: Colors.red.shade600,
    message: message,
    messageSize: 14,
    messageColor: Colors.white,
    duration: const Duration(seconds: 3),
    leftBarIndicatorColor: Colors.red.shade900,
  ).show(context);
}

/// Show success flushbar
void showSuccessFlushbar(BuildContext context, String message,
    {FlushbarPosition position = FlushbarPosition.TOP, Widget? mainButton}) {
  Flushbar(
    flushbarPosition: position,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(12),
    icon: const Icon(
      Icons.check_circle_outline,
      color: Colors.white,
      size: 28,
    ),
    backgroundColor: Colors.green.shade600,
    message: message,
    messageSize: 14,
    messageColor: Colors.white,
    duration: const Duration(seconds: 3),
    leftBarIndicatorColor: Colors.green.shade900,
    mainButton: mainButton,
  ).show(context);
}

/// Show validation error flushbar
void showValidationErrorFlushbar(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(12),
    icon: const Icon(
      Icons.warning_amber_rounded,
      color: Colors.white,
      size: 28,
    ),
    backgroundColor: Colors.orange.shade600,
    message: message,
    messageSize: 14,
    messageColor: Colors.white,
    duration: const Duration(seconds: 3),
    leftBarIndicatorColor: Colors.orange.shade900,
  ).show(context);
}

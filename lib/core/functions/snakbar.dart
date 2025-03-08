import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, [Color? color]) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 3),
        // margin: const EdgeInsets.symmetric(horizontal: 0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        backgroundColor: color ?? Colors.black,
        content: Text(message,
            style: const TextStyle(
              // fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            )),
      ),
    );
}

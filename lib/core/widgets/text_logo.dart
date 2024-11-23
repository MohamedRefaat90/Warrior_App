import 'package:flutter/material.dart';

class TextLogo extends StatelessWidget {
  final double fz;
  final double letterSpacing;
  const TextLogo({
    super.key,
    this.fz = 35,
    this.letterSpacing = 1.5,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      'Warrior',
      style: TextStyle(
        fontSize: fz,
        fontWeight: FontWeight.bold,
        fontFamily: 'kings',
        letterSpacing: letterSpacing,
        color: Colors.red[900],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class CustomTransition extends Page {
  final Widget child;
  final PageTransitionType transitionType;

  CustomTransition({
    required this.child,
    this.transitionType = PageTransitionType.rightToLeft,
  }) : super(key: ValueKey(_generateKey(child)));

  static String _generateKey(Widget child) {
    // Use a combination of the runtimeType of the child and a unique hash code
    return '${child.runtimeType}-${child.hashCode}';
  }

  @override
  Route createRoute(BuildContext context) {
    return PageTransition(
      type: transitionType,
      child: child,
      settings: this,
    );
  }
}

import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/features/Auth/presentation/provider/reset_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'validator_text.dart';

class PasswordValidationRules extends ConsumerWidget {
  PasswordValidationRules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ValidatorText(
          title: "Must must larger then 8", rule: isPassLengthLargerThan8),
      ValidatorText(
          title: "Must Contain Upper Character", rule: isContainUpperChar),
      ValidatorText(
          title: "Must Contain Lower Character", rule: isContainLowerChar),
      ValidatorText(title: "Must Contain Number", rule: isContainNum),
      ValidatorText(
          title: "Must Contain Special Character", rule: isContainSpecailChar),
    ]);
  }
}

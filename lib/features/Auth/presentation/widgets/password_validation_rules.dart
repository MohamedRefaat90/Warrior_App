import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'validator_text.dart';

class PasswordValidationRules extends ConsumerWidget {
  const PasswordValidationRules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ValidatorText(
          title: 'mustBeLargerThan8'.tr(context),
          rule: isPassLengthLargerThan8),
      ValidatorText(
          title: 'mustContainUpperChar'.tr(context), rule: isContainUpperChar),
      ValidatorText(
          title: 'mustContainLowerChar'.tr(context), rule: isContainLowerChar),
      ValidatorText(title: 'mustContainNumber'.tr(context), rule: isContainNum),
      ValidatorText(
          title: 'mustContainSpecialChar'.tr(context),
          rule: isContainSpecailChar),
    ]);
  }
}

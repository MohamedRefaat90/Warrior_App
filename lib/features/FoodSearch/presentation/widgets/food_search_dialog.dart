import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FoodSearchDialog extends StatefulWidget {
  const FoodSearchDialog({super.key});

  @override
  State<FoodSearchDialog> createState() => _FoodSearchDialogState();
}

class _FoodSearchDialogState extends State<FoodSearchDialog> {
  bool dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.l10n.foodScanner,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.foodSearchDescription,
          ),
          const SizedBox(height: 10),
          CheckboxListTile.adaptive(
            value: dontShowAgain,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              context.l10n.dontShowAgain,
              style: const TextStyle(fontSize: 12),
            ),
            onChanged: (value) async {
              setState(() {
                dontShowAgain = value!;
              });
              TalkerService.info(
                  'Food search alert preference updated: $dontShowAgain',
                  'FOOD_SEARCH_DIALOG');
              SharedPref.setBool(StorageKeys.foodSearchAlert, dontShowAgain);
            },
          ),
        ],
      ),
      actions: [
        CustomBTN(
            widget: Text(context.l10n.close),
            color: AppColors.black,
            padding: 12,
            width: double.infinity,
            press: () => context.pop())
      ],
    );
  }
}

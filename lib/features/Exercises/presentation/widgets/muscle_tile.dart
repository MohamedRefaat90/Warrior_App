import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/muscle_translations.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/loading_widget.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/image_error.dart';

class MuscleTile extends StatelessWidget {
  final MuscleModel muscle;
  final bool? isComingFromWorkoutScreen;
  const MuscleTile({
    super.key,
    required this.muscle,
    this.isComingFromWorkoutScreen,
  });

  @override
  Widget build(BuildContext context) {
    final translatedMuscleName = translateMuscleName(context, muscle.name);

    return Card(
      elevation: 20,
      child: ListTile(
        tileColor: const Color.fromARGB(30, 96, 125, 139),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => context.pushNamed(AppRouters.exercises, extra: {
          'id': muscle.id,
          'name': muscle.name,
          'isComingFromWorkoutScreen': isComingFromWorkoutScreen
        }),
        leading: CachedNetworkImage(
          imageUrl: muscle.image,
          width: ResponsiveUtils.value<double>(
            context,
            mobile: 50,
            tablet: 60,
            desktop: 70,
          ),
          placeholder: (context, url) => const CustomLoadingWidget(),
          errorWidget: (context, url, error) => const ImageError(),
        ),
        title: Text(
          translatedMuscleName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              muscle.exerciseCount.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              context.l10n.exercise,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

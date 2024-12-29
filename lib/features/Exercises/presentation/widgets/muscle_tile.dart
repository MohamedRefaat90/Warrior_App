import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MuscleTile extends StatelessWidget {
  final MuscleModel muscle;

  const MuscleTile({super.key, required this.muscle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        onTap: () => context.pushNamed(AppRouters.exercises,
            extra: {'id': muscle.id, 'name': muscle.name}),
        leading: CachedNetworkImage(
          imageUrl: muscle.image,
          width: 50,
        ),
        title: Text(muscle.name),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(muscle.exerciseCount.toString()),
            const Text("Exercise"),
          ],
        ),
      ),
    );
  }
}

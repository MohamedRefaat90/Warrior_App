import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MuscleTile extends StatelessWidget {
  final MuscleModel muscle;

  const MuscleTile({super.key, required this.muscle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: muscle.image,
            width: 50,
          ),
          title: Text(muscle.name),
          trailing: Text(muscle.exerciseCount.toString()),
        ),
      ),
    );
  }
}

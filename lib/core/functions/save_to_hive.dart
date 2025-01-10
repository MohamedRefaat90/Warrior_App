import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Future<void> saveToHive(Box box, List data) async {
  try {
    for (var item in data) {
      // Check if the item already exists (by id or another unique identifier)
      final exists = box.containsKey(item.id);
      if (exists == false) {
        await box.put(item.id, item);
      }
    }
  } catch (e) {
    debugPrint('Failed to save data to Hive: $e');
  }
}

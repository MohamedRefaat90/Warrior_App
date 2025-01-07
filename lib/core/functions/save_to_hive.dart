Future<void> saveToHive(var box, List data) async {
  for (var item in data) {
    // Check if the item already exists (by id or another unique identifier)
    final exists = box.values.any((e) => e.id == item.id);
    if (!exists) {
      await box.add(item);
    }
  }
}

extension StringExtension on String? {
  String capitalizeWord() {
    return this!.split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  bool isNull() {
    return this == null ? true : false;
  }

  String removeExtraSpaces() {
    return this!.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

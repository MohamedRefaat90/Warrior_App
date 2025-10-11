class AppVersion {
  String? version;
  String? build_number;
  bool? is_force_update;

  AppVersion({
    required this.version,
    required this.build_number,
    required this.is_force_update,
  });

  factory AppVersion.fromMap(Map<String, dynamic> map) {
    return AppVersion(
      version: map['data']['version'] as String? ?? '',
      build_number: map['data']['build_number'] as String? ?? '',
      is_force_update: map['data']['force_update'] as bool? ?? false,
    );
  }
}

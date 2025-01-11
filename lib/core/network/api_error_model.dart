class ApiErrorModel {
  final String? message;
  final int? code;

  ApiErrorModel({
    required this.message,
    this.code,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      ApiErrorModel(message: json[''], code: json['']);

  Map<String, dynamic> toJson() => {
        'message': message,
        'code': code,
      };
}

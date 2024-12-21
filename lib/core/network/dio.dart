import 'package:Warrior/core/constants/apis_url.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHandler {
  static Dio? _dio;

  static Dio getDio() {
    Duration timeout = const Duration(seconds: 20);

    _dio ??= Dio()
      ..options.baseUrl = ApisUrl.baseurl
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout
      ..interceptors.add(PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));

    return _dio!;
  }
}

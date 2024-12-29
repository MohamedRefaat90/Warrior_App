import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHandler {
  static late Dio dio;

  static Future<void> initDio() async {
    Duration timeout = const Duration(seconds: 30);

    dio = Dio()
      ..options.baseUrl = ApisUrl.baseurl
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            "Token ${await SecureStorageHandler.read(key: 'Token')}"
      }
      ..interceptors.add(PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
  }
}

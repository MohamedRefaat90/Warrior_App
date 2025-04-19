import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';

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
      }
      ..interceptors.add(TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
            printRequestHeaders: true,
            printResponseHeaders: false,
            printResponseMessage: true,
            printResponseData: true,
            printErrorData: true,
            printErrorHeaders: false,
            printErrorMessage: true,
            printRequestData: true),
      ))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Authorization header conditionally
          if (!options.path.startsWith("auth/")) {
            String? token =
                await SecureStorageHandler.read(key: StorageKeys.token);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = "Token $token";
            }
          }
          return handler.next(options);
        },
      ));
  }
}

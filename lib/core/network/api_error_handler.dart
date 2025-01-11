import 'package:Warrior/core/network/api_error_model.dart';
import 'package:dio/dio.dart';

ApiErrorModel _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.CONNECT_TIMEOUT.getFailure();
    case DioExceptionType.sendTimeout:
      return DataSource.SEND_TIMEOUT.getFailure();
    case DioExceptionType.receiveTimeout:
      return DataSource.RECEIVE_TIMEOUT.getFailure();
    case DioExceptionType.badResponse:
      if (error.response != null &&
          error.response?.data != null &&
          error.response?.data['message'] != null) {
        // Use the `message` from the custom response
        return ApiErrorModel(
          code: error.response?.statusCode ?? ResponseCode.DEFAULT,
          message: error.response?.data['message'],
        );
      } else {
        return DataSource.DEFAULT.getFailure();
      }
    case DioExceptionType.unknown:
      return DataSource.DEFAULT.getFailure();
    case DioExceptionType.cancel:
      return DataSource.CANCEL.getFailure();
    case DioExceptionType.connectionError:
      return DataSource.DEFAULT.getFailure();
    case DioExceptionType.badCertificate:
      return DataSource.DEFAULT.getFailure();
  }
}

// Adjusted DataSource enum to include TIMEOUT for better grouping
enum DataSource {
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTHORIZED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  TIMEOUT, // Groups connectionTimeout, sendTimeout, and receiveTimeout
  CANCEL,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  DEFAULT,
  CONNECT_TIMEOUT,
  SEND_TIMEOUT,
  RECEIVE_TIMEOUT,
}

// Enhanced DataSource extension
extension DataSourceExtension on DataSource {
  ApiErrorModel getFailure() {
    final int code;
    final String message;

    switch (this) {
      case DataSource.NO_CONTENT:
        code = ResponseCode.NO_CONTENT;
        message = ResponseMessage.NO_CONTENT;
        break;

      case DataSource.BAD_REQUEST:
        code = ResponseCode.BAD_REQUEST;
        message = ResponseMessage.BAD_REQUEST;
        break;

      case DataSource.FORBIDDEN:
        code = ResponseCode.FORBIDDEN;
        message = ResponseMessage.FORBIDDEN;
        break;

      case DataSource.UNAUTHORIZED:
        code = ResponseCode.UNAUTHORIZED;
        message = ResponseMessage.UNAUTHORIZED;
        break;

      case DataSource.NOT_FOUND:
        code = ResponseCode.NOT_FOUND;
        message = ResponseMessage.NOT_FOUND;
        break;

      case DataSource.INTERNAL_SERVER_ERROR:
        code = ResponseCode.INTERNAL_SERVER_ERROR;
        message = ResponseMessage.INTERNAL_SERVER_ERROR;
        break;

      case DataSource.TIMEOUT:
        code = ResponseCode.TIMEOUT;
        message = ResponseMessage.TIMEOUT;
        break;

      case DataSource.CANCEL:
        code = ResponseCode.CANCEL;
        message = ResponseMessage.CANCEL;
        break;

      case DataSource.CACHE_ERROR:
        code = ResponseCode.CACHE_ERROR;
        message = ResponseMessage.CACHE_ERROR;
        break;

      case DataSource.NO_INTERNET_CONNECTION:
        code = ResponseCode.NO_INTERNET_CONNECTION;
        message = ResponseMessage.NO_INTERNET_CONNECTION;
        break;

      default:
        code = ResponseCode.DEFAULT;
        message = ResponseMessage.DEFAULT;
        break;
    }

    return ApiErrorModel(code: code, message: message);
  }
}

// Simplified ResponseCode
class ResponseCode {
  static const int SUCCESS = 200;
  static const int NO_CONTENT = 201;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int FORBIDDEN = 403;
  static const int NOT_FOUND = 404;
  static const int INTERNAL_SERVER_ERROR = 500;

  // Local status codes
  static const int TIMEOUT = -1;
  static const int CANCEL = -2;
  static const int CACHE_ERROR = -3;
  static const int NO_INTERNET_CONNECTION = -4;
  static const int DEFAULT = -5;
}

// Simplified ResponseMessage
class ResponseMessage {
  static const String NO_CONTENT = ApiErrors.noContent;
  static const String BAD_REQUEST = ApiErrors.badRequestError;
  static const String FORBIDDEN = ApiErrors.forbiddenError;
  static const String UNAUTHORIZED = ApiErrors.unauthorizedError;
  static const String NOT_FOUND = ApiErrors.notFoundError;
  static const String INTERNAL_SERVER_ERROR = ApiErrors.internalServerError;

  // Local status codes
  static const String TIMEOUT = ApiErrors.timeoutError;
  static const String CANCEL = ApiErrors.defaultError;
  static const String CACHE_ERROR = ApiErrors.cacheError;
  static const String NO_INTERNET_CONNECTION = ApiErrors.noInternetError;
  static const String DEFAULT = ApiErrors.defaultError;
}

// Updated ErrorHandler
class ErrorHandler implements Exception {
  late ApiErrorModel apiErrorModel;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      apiErrorModel = _handleError(error);
    } else {
      apiErrorModel = DataSource.DEFAULT.getFailure();
    }
  }
}

class ApiErrors {
  static const String badRequestError = "badRequestError";
  static const String noContent = "noContent";
  static const String forbiddenError = "forbiddenError";
  static const String unauthorizedError = "unauthorizedError";
  static const String notFoundError = "notFoundError";
  static const String conflictError = "conflictError";
  static const String internalServerError = "internalServerError";
  static const String unknownError = "unknownError";
  static const String timeoutError = "timeoutError";
  static const String defaultError = "defaultError";
  static const String cacheError = "cacheError";
  static const String noInternetError = "noInternetError";
  static const String loadingMessage = "loading_message";
  static const String retryAgainMessage = "retry_again_message";
  static const String ok = "Ok";
}

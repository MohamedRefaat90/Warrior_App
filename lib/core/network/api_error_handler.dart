import 'package:Warrior/core/network/api_error_model.dart';
import 'package:dio/dio.dart';

ApiErrorModel _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.connectTimeout.getFailure();
    case DioExceptionType.sendTimeout:
      return DataSource.sendTimeout.getFailure();
    case DioExceptionType.receiveTimeout:
      return DataSource.receiveTimeout.getFailure();
    case DioExceptionType.badResponse:
      if (error.response != null &&
          error.response?.data != null &&
          error.response?.data['message'] != null) {
        // Use the `message` from the custom response
        return ApiErrorModel(
          code: error.response?.statusCode ?? ResponseCode.defaultError,
          message: error.response?.data['message'],
        );
      } else {
        return DataSource.defaultError.getFailure();
      }
    case DioExceptionType.unknown:
      return DataSource.defaultError.getFailure();
    case DioExceptionType.cancel:
      return DataSource.cancel.getFailure();
    case DioExceptionType.connectionError:
      return DataSource.defaultError.getFailure();
    case DioExceptionType.badCertificate:
      return DataSource.defaultError.getFailure();
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

// Adjusted DataSource enum to include TIMEOUT for better grouping
enum DataSource {
  noContent,
  badRequest,
  forbidden,
  unauthorized,
  notFound,
  internalServerError,
  timeout,
  cancel,
  cacheError,
  noInternetConnection,
  defaultError,
  connectTimeout,
  sendTimeout,
  receiveTimeout,
}

// Updated ErrorHandler
class ErrorHandler implements Exception {
  late ApiErrorModel apiErrorModel;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      apiErrorModel = _handleError(error);
    } else {
      apiErrorModel = DataSource.defaultError.getFailure();
    }
  }
}

// Simplified ResponseCode
class ResponseCode {
  static const int success = 200;
  static const int noContent = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;

  // Local status codes
  static const int timeout = -1;
  static const int cancel = -2;
  static const int cacheError = -3;
  static const int noInternetConnection = -4;
  static const int defaultError = -5;
}

// Simplified ResponseMessage
class ResponseMessage {
  static const String noContent = ApiErrors.noContent;
  static const String badRequest = ApiErrors.badRequestError;
  static const String forbidden = ApiErrors.forbiddenError;
  static const String unauthorized = ApiErrors.unauthorizedError;
  static const String notFound = ApiErrors.notFoundError;
  static const String internalServerError = ApiErrors.internalServerError;

  // Local status codes
  static const String timeout = ApiErrors.timeoutError;
  static const String cancel = ApiErrors.defaultError;
  static const String cacheError = ApiErrors.cacheError;
  static const String noInternetConnection = ApiErrors.noInternetError;
  static const String defaultError = ApiErrors.defaultError;
}

// Enhanced DataSource extension
extension DataSourceExtension on DataSource {
  ApiErrorModel getFailure() {
    final int code;
    final String message;

    switch (this) {
      case DataSource.noContent:
        code = ResponseCode.noContent;
        message = ResponseMessage.noContent;
        break;

      case DataSource.badRequest:
        code = ResponseCode.badRequest;
        message = ResponseMessage.badRequest;
        break;

      case DataSource.forbidden:
        code = ResponseCode.forbidden;
        message = ResponseMessage.forbidden;
        break;

      case DataSource.unauthorized:
        code = ResponseCode.unauthorized;
        message = ResponseMessage.unauthorized;
        break;

      case DataSource.notFound:
        code = ResponseCode.notFound;
        message = ResponseMessage.notFound;
        break;

      case DataSource.internalServerError:
        code = ResponseCode.internalServerError;
        message = ResponseMessage.internalServerError;
        break;

      case DataSource.timeout:
      case DataSource.connectTimeout:
      case DataSource.sendTimeout:
      case DataSource.receiveTimeout:
        code = ResponseCode.timeout;
        message = ResponseMessage.timeout;
        break;

      case DataSource.cancel:
        code = ResponseCode.cancel;
        message = ResponseMessage.cancel;
        break;

      case DataSource.cacheError:
        code = ResponseCode.cacheError;
        message = ResponseMessage.cacheError;
        break;

      case DataSource.noInternetConnection:
        code = ResponseCode.noInternetConnection;
        message = ResponseMessage.noInternetConnection;
        break;

      case DataSource.defaultError:
        code = ResponseCode.defaultError;
        message = ResponseMessage.defaultError;
        break;
    }

    return ApiErrorModel(code: code, message: message);
  }
}

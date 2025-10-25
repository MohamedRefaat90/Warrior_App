import 'package:Warrior/core/network/api_error_model.dart';
import 'package:dio/dio.dart';

/// Extract user-friendly error message from API response
ApiErrorModel _extractApiErrorMessage(DioException error) {
  final response = error.response;
  final statusCode = response?.statusCode ?? ResponseCode.defaultError;

  // Try to extract message from response data
  String? message;
  try {
    if (response?.data != null) {
      final data = response!.data;

      if (data is Map) {
        // Try multiple common message keys
        message =
            data['message'] ?? data['error'] ?? data['detail'] ?? data['msg'];
      } else if (data is String) {
        message = data;
      }
    }
  } catch (_) {
    // If extraction fails, use default based on status code
  }

  // If we got a message from API, use it
  if (message != null && message.isNotEmpty) {
    return ApiErrorModel(code: statusCode, message: message);
  }

  // Otherwise, use status code-based fallback
  return _getStatusCodeFailure(statusCode);
}

/// Get appropriate error based on HTTP status code
ApiErrorModel _getStatusCodeFailure(int statusCode) {
  switch (statusCode) {
    case ResponseCode.badRequest:
      return DataSource.badRequest.getFailure();
    case ResponseCode.unauthorized:
      return DataSource.unauthorized.getFailure();
    case ResponseCode.forbidden:
      return DataSource.forbidden.getFailure();
    case ResponseCode.notFound:
      return DataSource.notFound.getFailure();
    case ResponseCode.internalServerError:
      return DataSource.internalServerError.getFailure();
    default:
      return DataSource.defaultError.getFailure();
  }
}

ApiErrorModel _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.connectTimeout.getFailure();
    case DioExceptionType.sendTimeout:
      return DataSource.sendTimeout.getFailure();
    case DioExceptionType.receiveTimeout:
      return DataSource.receiveTimeout.getFailure();
    case DioExceptionType.badResponse:
      return _extractApiErrorMessage(error);
    case DioExceptionType.unknown:
      return DataSource.defaultError.getFailure();
    case DioExceptionType.cancel:
      return DataSource.cancel.getFailure();
    case DioExceptionType.connectionError:
      return DataSource.noInternetConnection.getFailure();
    case DioExceptionType.badCertificate:
      return DataSource.defaultError.getFailure();
  }
}

class ApiErrors {
  static const String badRequestError = "Bad request. Please check your input";
  static const String noContent = "No content available";
  static const String forbiddenError =
      "Access denied. You don't have permission";
  static const String unauthorizedError = "Unauthorized. Please login again";
  static const String notFoundError = "Resource not found";
  static const String conflictError = "Conflict occurred";
  static const String internalServerError =
      "Server error. Please try again later";
  static const String unknownError = "Something went wrong";
  static const String timeoutError = "Connection timeout. Please try again";
  static const String defaultError = "Something went wrong. Please try again";
  static const String cacheError = "Cache error occurred";
  static const String noInternetError =
      "No internet connection. Please check your network";
  static const String loadingMessage = "Loading...";
  static const String retryAgainMessage = "Please try again";
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

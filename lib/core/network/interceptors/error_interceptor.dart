import 'package:dio/dio.dart';
import 'package:rockster/core/exceptions/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _handleError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
    ));
  }

  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');
      
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      
      case DioExceptionType.cancel:
        return AppException('Request cancelled');
      
      default:
        return AppException('Unexpected error occurred');
    }
  }

  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return AppException('No response from server');
    }

    switch (response.statusCode) {
      case 400:
        return ValidationException(
          _extractErrorMessage(response.data) ?? 'Invalid request data',
        );
      
      case 401:
        return AuthenticationException('Session expired. Please login again.');
      
      case 403:
        return AuthorizationException('You don\'t have permission to perform this action.');
      
      case 404:
        return NotFoundException('The requested resource was not found.');
      
      case 429:
        return AppException('Too many requests. Please try again later.');
      
      case 500:
      case 502:
      case 503:
        return ServerException('Server error. Please try again later.');
      
      default:
        return AppException('Request failed with status: ${response.statusCode}');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message'] ?? data['error'] ?? data['detail'];
    }
    return null;
  }
}

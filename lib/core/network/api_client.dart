import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rockster/core/network/interceptors/auth_interceptor.dart';
import 'package:rockster/core/network/interceptors/error_interceptor.dart';
import 'package:rockster/core/network/interceptors/logging_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;

  ApiClient._internal() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://rockster-production.up.railway.app';
    }
    if (kIsWeb) {
      // Use local backend for development verification
      return 'http://localhost:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
  
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      );

  void _setupInterceptors() {
    _dio.interceptors.clear();
    
    // Add interceptors in order
    _dio.interceptors.add(AuthInterceptor());
    
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
    
    _dio.interceptors.add(ErrorInterceptor());
  }

  // Retry configuration
  Future<Response<T>> retryRequest<T>(
    Future<Response<T>> Function() request, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await request();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;

        // Only retry on network errors or 5xx errors
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError ||
              (e.response?.statusCode != null && e.response!.statusCode! >= 500)) {
            await Future.delayed(delay);
            delay *= 2; // Exponential backoff
            continue;
          }
        }
        rethrow;
      }
    }
  }
}

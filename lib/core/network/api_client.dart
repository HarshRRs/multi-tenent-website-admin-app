import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rockster/core/network/interceptors/auth_interceptor.dart';
import 'package:rockster/core/network/interceptors/error_interceptor.dart';
import 'package:rockster/core/network/interceptors/logging_interceptor.dart';

import 'package:flutter/material.dart';

class ApiClient {
  static ApiClient? _instance;
  static ApiClient getInstance(GlobalKey<ScaffoldMessengerState>? messengerKey) {
    _instance ??= ApiClient._internal(messengerKey);
    return _instance!;
  }

  late final Dio _dio;
  final GlobalKey<ScaffoldMessengerState>? messengerKey;
  
  Dio get dio => _dio;

  ApiClient._internal(this.messengerKey) {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  // Change this to your laptop's IP (e.g., 192.168.1.5) to test on a physical Android phone
  static const String localIp = '10.0.2.2'; // 10.0.2.2 is for Emulator only

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://rockster-production.up.railway.app/';
    }
    if (kIsWeb) {
      return 'http://localhost:3000/';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://$localIp:3000/';
    }
    return 'http://localhost:3000/';
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
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      );

  void _setupInterceptors() {
    _dio.interceptors.clear();
    
    // Add interceptors in order
    _dio.interceptors.add(AuthInterceptor());
    
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
    
    _dio.interceptors.add(ErrorInterceptor(messengerKey));
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

import 'package:dio/dio.dart';
import 'package:event_bite/core/utils/secure_storage.dart';
import 'package:event_bite/core/network/api_client.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage = SecureStorage();
  bool _isRefreshing = false;
  final _requestsQueue = <Map<String, dynamic>>[];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final options = err.requestOptions;

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _requestsQueue.add({
          'options': options,
          'handler': handler,
        });
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false;
          _clearQueue(err);
          handler.next(err);
          return;
        }

        // Create a new Dio instance to avoid interceptor loops
        final dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];

          await _secureStorage.setAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await _secureStorage.setRefreshToken(newRefreshToken);
          }

          _isRefreshing = false;

          // Retry the original request
          options.headers['Authorization'] = 'Bearer $newAccessToken';
          final cloneReq = await _retry(options);
          handler.resolve(cloneReq);

          // Process queued requests
          for (var request in _requestsQueue) {
            final reqOptions = request['options'] as RequestOptions;
            final reqHandler = request['handler'] as ErrorInterceptorHandler;

            reqOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            try {
              final response = await _retry(reqOptions);
              reqHandler.resolve(response);
            } catch (e) {
              if (e is DioException) {
                reqHandler.next(e);
              } else {
                 // Should not happen, but safe to ignore or reject
                 reqHandler.reject(DioException(requestOptions: reqOptions, error: e));
              }
            }
          }
          _requestsQueue.clear();
        } else {
           _handleRefreshError(err, handler);
        }
      } catch (e) {
        _handleRefreshError(err, handler);
      }
    } else {
      handler.next(err);
    }
  }

  void _handleRefreshError(DioException err, ErrorInterceptorHandler handler) async {
     _isRefreshing = false;
     await _secureStorage.clearTokens();
     _clearQueue(err);
     handler.next(err);
  }

  void _clearQueue(DioException error) {
      for (var request in _requestsQueue) {
         final handler = request['handler'] as ErrorInterceptorHandler;
         handler.next(error);
      }
      _requestsQueue.clear();
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
    // We don't add AuthInterceptor here because we manually set the header
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }
}

class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

class AuthenticationException extends AppException {
  AuthenticationException(String message) : super(message, 'AUTH_ERROR');
}

class AuthorizationException extends AppException {
  AuthorizationException(String message) : super(message, 'AUTHORIZATION_ERROR');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, 'VALIDATION_ERROR');
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 'NOT_FOUND');
}

class ServerException extends AppException {
  ServerException(String message) : super(message, 'SERVER_ERROR');
}

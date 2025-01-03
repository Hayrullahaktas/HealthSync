abstract class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  ApiException(this.message, {this.code, this.data});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([String? message])
      : super(message ?? 'Network connection failed');
}

class ServerException extends ApiException {
  ServerException([String? message, String? code, dynamic data])
      : super(message ?? 'Server error occurred', code: code, data: data);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String? message])
      : super(message ?? 'Unauthorized access');
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;

  ValidationException(this.errors, [String? message])
      : super(message ?? 'Validation failed');
}

class NotFoundException extends ApiException {
  NotFoundException([String? message])
      : super(message ?? 'Resource not found');
}

class UnknownException extends ApiException {
  UnknownException([String? message])
      : super(message ?? 'An unknown error occurred');
}
/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Network connection exception
class NetworkException extends ApiException {
  NetworkException(super.message);
}

/// Request timeout exception
class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

/// Bad request exception (400)
class BadRequestException extends ApiException {
  BadRequestException(super.message) : super(statusCode: 400);
}

/// Unauthorized exception (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

/// Forbidden exception (403)
class ForbiddenException extends ApiException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

/// Not found exception (404)
class NotFoundException extends ApiException {
  NotFoundException(super.message) : super(statusCode: 404);
}

/// Validation exception (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(super.message, {this.errors}) : super(statusCode: 422);

  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return fieldErrors?.toString();
  }
}

/// Server exception (500)
class ServerException extends ApiException {
  ServerException(super.message) : super(statusCode: 500);
}

/// Cache exception
class CacheException extends ApiException {
  CacheException(super.message);
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Database error']);

  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation error']);

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found']);

  @override
  String toString() => 'NotFoundException: $message';
}

class ExcelException implements Exception {
  final String message;
  const ExcelException([this.message = 'Excel error']);

  @override
  String toString() => 'ExcelException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication error']);

  @override
  String toString() => 'AuthException: $message';
}

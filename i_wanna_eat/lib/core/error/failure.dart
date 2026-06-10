import 'package:dio/dio.dart';

sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Сеть недоступна']);
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([super.message = 'Сессия истекла']);
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Произошла ошибка на сервере. Повторите попытку позже']);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Неизвестная ошибка']);
}

AppFailure mapDioException(DioException exception) {
  final statusCode = exception.response?.statusCode;
  if (exception.type == DioExceptionType.connectionError ||
      exception.type == DioExceptionType.connectionTimeout ||
      exception.type == DioExceptionType.unknown) {
    return const NetworkFailure();
  }
  if (statusCode == 401) {
    return const UnauthorizedFailure();
  }
  if (statusCode != null && statusCode >= 500 && statusCode <= 504) {
    return const ServerFailure();
  }
  if (statusCode == 400 || statusCode == 422) {
    return const ValidationFailure('Проверьте корректность введенных данных');
  }
  return UnknownFailure(exception.message ?? 'Неизвестная ошибка');
}

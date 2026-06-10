import 'package:dio/dio.dart';
import 'package:i_wanna_eat/core/error/failure.dart';
import 'package:i_wanna_eat/features/auth/data/datasources/auth_api.dart';
import 'package:i_wanna_eat/features/auth/domain/entities/auth_tokens.dart';
import 'package:i_wanna_eat/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authApi);

  final AuthApi _authApi;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _authApi.login(email: email, password: password);
      return dto.toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<AuthTokens> refresh({required String refreshToken}) async {
    try {
      final dto = await _authApi.refresh(refreshToken: refreshToken);
      return dto.toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<AuthTokens> register({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _authApi.register(email: email, password: password);
      return dto.toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

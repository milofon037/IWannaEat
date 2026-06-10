import 'package:dio/dio.dart';
import 'package:i_wanna_eat/features/auth/data/models/auth_tokens_dto.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthTokensDto> register({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthTokensDto.fromJson(response.data!);
  }

  Future<AuthTokensDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthTokensDto.fromJson(response.data!);
  }

  Future<AuthTokensDto> refresh({
    required String refreshToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthTokensDto.fromJson(response.data!);
  }
}

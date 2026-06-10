import 'package:i_wanna_eat/features/auth/domain/entities/auth_tokens.dart';

abstract interface class AuthRepository {
  Future<AuthTokens> register({
    required String email,
    required String password,
  });

  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<AuthTokens> refresh({
    required String refreshToken,
  });
}

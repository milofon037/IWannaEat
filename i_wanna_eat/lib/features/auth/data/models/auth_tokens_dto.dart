import 'package:i_wanna_eat/features/auth/domain/entities/auth_tokens.dart';

class AuthTokensDto {
  const AuthTokensDto({
    required this.userId,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String userId;
  final String role;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory AuthTokensDto.fromJson(Map<String, dynamic> json) {
    return AuthTokensDto(
      userId: json['userId'] as String,
      role: json['role'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  AuthTokens toEntity() => AuthTokens(
        userId: userId,
        role: role,
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
      );
}

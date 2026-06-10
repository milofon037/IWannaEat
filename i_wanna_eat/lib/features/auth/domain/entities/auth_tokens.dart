class AuthTokens {
  const AuthTokens({
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
}

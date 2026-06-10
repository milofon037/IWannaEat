import 'package:i_wanna_eat/features/auth/domain/entities/auth_tokens.dart';
import 'package:i_wanna_eat/features/auth/domain/repositories/auth_repository.dart';

class RefreshUseCase {
  RefreshUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokens> call(String refreshToken) {
    return _repository.refresh(refreshToken: refreshToken);
  }
}

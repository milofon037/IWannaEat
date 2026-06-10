import 'package:i_wanna_eat/features/auth/domain/entities/auth_tokens.dart';
import 'package:i_wanna_eat/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokens> call({
    required String email,
    required String password,
  }) {
    return _repository.register(email: email, password: password);
  }
}

import 'package:i_wanna_eat/core/storage/token_storage.dart';

class LogoutUseCase {
  LogoutUseCase(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> call() {
    return _tokenStorage.clear();
  }
}

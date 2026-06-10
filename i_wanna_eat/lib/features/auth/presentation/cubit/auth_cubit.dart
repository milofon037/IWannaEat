import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_wanna_eat/core/error/failure.dart';
import 'package:i_wanna_eat/core/session/session_controller.dart';
import 'package:i_wanna_eat/core/storage/token_storage.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/login_usecase.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/logout_usecase.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/register_usecase.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/refresh_usecase.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.needsProfileSetup = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool needsProfileSetup;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    bool? needsProfileSetup,
    bool? isLoading,
    String? errorMessage,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      needsProfileSetup: needsProfileSetup ?? this.needsProfileSetup,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, needsProfileSetup, isLoading, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required RegisterUseCase registerUseCase,
    required LoginUseCase loginUseCase,
    required RefreshUseCase refreshUseCase,
    required LogoutUseCase logoutUseCase,
    required TokenStorage tokenStorage,
    required SessionController sessionController,
  })  : _registerUseCase = registerUseCase,
        _loginUseCase = loginUseCase,
        _refreshUseCase = refreshUseCase,
        _logoutUseCase = logoutUseCase,
        _tokenStorage = tokenStorage,
        _sessionController = sessionController,
        super(const AuthState(status: AuthStatus.unknown)) {
    _unauthorizedSub = _sessionController.unauthorizedStream.listen((_) {
      forceLogout('Сессия истекла');
    });
  }

  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  final RefreshUseCase _refreshUseCase;
  final LogoutUseCase _logoutUseCase;
  final TokenStorage _tokenStorage;
  final SessionController _sessionController;
  late final StreamSubscription<void> _unauthorizedSub;

  Future<void> initialize() async {
    final access = await _tokenStorage.readAccessToken();
    if (access == null || access.isEmpty) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    final needsProfileSetup = !(await _tokenStorage.readProfileCompleted());
    emit(
      AuthState(
        status: AuthStatus.authenticated,
        needsProfileSetup: needsProfileSetup,
      ),
    );
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    try {
      final tokens = await _registerUseCase(email: email, password: password);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _tokenStorage.setProfileCompleted(false);
      emit(
        const AuthState(
          status: AuthStatus.authenticated,
          needsProfileSetup: true,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      );
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Не удалось зарегистрироваться',
        ),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    try {
      final tokens = await _loginUseCase(email: email, password: password);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final profileCompleted = await _tokenStorage.readProfileCompleted();
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          needsProfileSetup: !profileCompleted,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      );
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Не удалось выполнить вход',
        ),
      );
    }
  }

  Future<void> tryRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return forceLogout();
    }
    try {
      final tokens = await _refreshUseCase(refreshToken);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    } catch (_) {
      await forceLogout('Сессия истекла');
    }
  }

  Future<void> markProfileCompleted() async {
    await _tokenStorage.setProfileCompleted(true);
    emit(
      const AuthState(
        status: AuthStatus.authenticated,
        needsProfileSetup: false,
      ),
    );
  }

  Future<void> forceLogout([String? message]) async {
    await _logoutUseCase();
    emit(
      AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: message,
      ),
    );
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  @override
  Future<void> close() async {
    await _unauthorizedSub.cancel();
    return super.close();
  }
}

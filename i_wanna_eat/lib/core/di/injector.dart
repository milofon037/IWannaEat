import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:i_wanna_eat/core/constants/app_constants.dart';
import 'package:i_wanna_eat/core/network/dio_client.dart';
import 'package:i_wanna_eat/core/session/session_controller.dart';
import 'package:i_wanna_eat/core/storage/token_storage.dart';
import 'package:i_wanna_eat/features/auth/data/datasources/auth_api.dart';
import 'package:i_wanna_eat/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:i_wanna_eat/features/auth/domain/repositories/auth_repository.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/login_usecase.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/logout_usecase.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/refresh_usecase.dart';
import 'package:i_wanna_eat/features/auth/domain/usecases/register_usecase.dart';
import 'package:i_wanna_eat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:i_wanna_eat/features/profile/data/datasources/profile_api.dart';
import 'package:i_wanna_eat/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:i_wanna_eat/features/profile/domain/repositories/profile_repository.dart';
import 'package:i_wanna_eat/features/profile/domain/usecases/get_allergies_usecase.dart';
import 'package:i_wanna_eat/features/profile/domain/usecases/update_allergies_usecase.dart';
import 'package:i_wanna_eat/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:i_wanna_eat/features/profile/presentation/cubit/profile_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AuthCubit>()) {
    return;
  }

  getIt.registerLazySingleton(FlutterSecureStorage.new);
  getIt.registerLazySingleton(() => TokenStorage(getIt()));
  getIt.registerLazySingleton(SessionController.new);

  getIt.registerLazySingleton<Dio>(
    () => DioClientFactory(
      baseUrl: AppConstants.apiBaseUrl,
      tokenStorage: getIt(),
      sessionController: getIt(),
    ).create(),
  );

  getIt.registerLazySingleton(() => AuthApi(getIt()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RefreshUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  getIt.registerLazySingleton(() => ProfileApi(getIt()));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => GetAllergiesUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateAllergiesUseCase(getIt()));

  getIt.registerFactory(
    () => AuthCubit(
      registerUseCase: getIt(),
      loginUseCase: getIt(),
      refreshUseCase: getIt(),
      logoutUseCase: getIt(),
      tokenStorage: getIt(),
      sessionController: getIt(),
    ),
  );

  getIt.registerFactory(
    () => ProfileCubit(
      getAllergiesUseCase: getIt(),
      updateProfileUseCase: getIt(),
      updateAllergiesUseCase: getIt(),
    ),
  );
}

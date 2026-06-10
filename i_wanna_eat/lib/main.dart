import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i_wanna_eat/core/connectivity/connectivity_cubit.dart';
import 'package:i_wanna_eat/core/di/injector.dart';
import 'package:i_wanna_eat/core/router/app_router.dart';
import 'package:i_wanna_eat/core/theme/app_theme.dart';
import 'package:i_wanna_eat/core/widgets/no_internet_overlay.dart';
import 'package:i_wanna_eat/features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>()..initialize();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = createRouter(_authCubit);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: router,
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              BlocBuilder<ConnectivityCubit, bool>(
                builder: (context, isOnline) {
                  if (isOnline) return const SizedBox.shrink();
                  return const Positioned.fill(child: NoInternetOverlay());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

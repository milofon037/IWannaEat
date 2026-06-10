import 'package:go_router/go_router.dart';
import 'package:i_wanna_eat/core/router/app_routes.dart';
import 'package:i_wanna_eat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:i_wanna_eat/features/auth/presentation/pages/login_page.dart';
import 'package:i_wanna_eat/features/auth/presentation/pages/onboarding_page.dart';
import 'package:i_wanna_eat/features/auth/presentation/pages/register_page.dart';
import 'package:i_wanna_eat/features/profile/presentation/pages/home_page.dart';
import 'package:i_wanna_eat/features/profile/presentation/pages/profile_setup_page.dart';

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.matchedLocation;
      final publicRoutes = {
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
      };

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      if (authState.status == AuthStatus.unauthenticated &&
          !publicRoutes.contains(location)) {
        return AppRoutes.onboarding;
      }

      if (authState.status == AuthStatus.authenticated) {
        if (authState.needsProfileSetup && location != AppRoutes.profileSetup) {
          return AppRoutes.profileSetup;
        }
        if (!authState.needsProfileSetup &&
            (publicRoutes.contains(location) || location == AppRoutes.profileSetup)) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

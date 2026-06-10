import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i_wanna_eat/core/constants/app_constants.dart';
import 'package:i_wanna_eat/core/router/app_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'IWannaEat',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing16),
              const Text(
                'Подбор рецептов с учетом ваших аллергий и диеты',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Войти'),
              ),
              const SizedBox(height: AppConstants.spacing8),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.register),
                child: const Text('Регистрация'),
              ),
              const SizedBox(height: AppConstants.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_wanna_eat/core/constants/app_constants.dart';
import 'package:i_wanna_eat/features/auth/presentation/cubit/auth_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IWannaEat'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().forceLogout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.horizontalPadding),
          child: Text(
            'Главный экран (MVP-заглушка).\nСледующие фазы: рецепты, плейлисты, AI-чат.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

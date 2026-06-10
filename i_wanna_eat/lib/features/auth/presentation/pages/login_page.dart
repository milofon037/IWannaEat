import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_wanna_eat/core/connectivity/connectivity_cubit.dart';
import 'package:i_wanna_eat/core/constants/app_constants.dart';
import 'package:i_wanna_eat/core/router/app_routes.dart';
import 'package:i_wanna_eat/core/utils/validators.dart';
import 'package:i_wanna_eat/features/auth/presentation/cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<AuthCubit>().clearMessage();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Вход')),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: BlocBuilder2(
            builder: (context, authState, isOnline) {
              final isLoading = authState.isLoading;
              final canSubmit = isOnline && !isLoading;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Введите пароль' : null,
                      decoration: const InputDecoration(labelText: 'Пароль'),
                    ),
                    const SizedBox(height: AppConstants.spacing24),
                    ElevatedButton(
                      onPressed: canSubmit
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                              }
                            }
                          : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Войти'),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Нет аккаунта? Зарегистрироваться'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BlocBuilder2 extends StatelessWidget {
  const BlocBuilder2({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, AuthState authState, bool isOnline) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<ConnectivityCubit, bool>(
          builder: (context, isOnline) {
            return builder(context, authState, isOnline);
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_wanna_eat/core/connectivity/connectivity_cubit.dart';
import 'package:i_wanna_eat/core/constants/app_constants.dart';
import 'package:i_wanna_eat/core/router/app_routes.dart';
import 'package:i_wanna_eat/core/utils/validators.dart';
import 'package:i_wanna_eat/features/auth/presentation/cubit/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
        appBar: AppBar(title: const Text('Регистрация')),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return BlocBuilder<ConnectivityCubit, bool>(
                builder: (context, isOnline) {
                  final isLoading = authState.isLoading;
                  final canSubmit = isOnline && !isLoading;

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: AppConstants.spacing16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: Validators.password,
                          decoration: const InputDecoration(labelText: 'Пароль'),
                        ),
                        const SizedBox(height: AppConstants.spacing16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Повторите пароль';
                            }
                            if (value != _passwordController.text) {
                              return 'Пароли не совпадают';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(labelText: 'Повтор пароля'),
                        ),
                        const SizedBox(height: AppConstants.spacing24),
                        ElevatedButton(
                          onPressed: canSubmit
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthCubit>().register(
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
                              : const Text('Создать аккаунт'),
                        ),
                        const SizedBox(height: AppConstants.spacing8),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: const Text('Уже есть аккаунт? Войти'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

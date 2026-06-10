import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_wanna_eat/core/connectivity/connectivity_cubit.dart';
import 'package:i_wanna_eat/core/constants/app_constants.dart';
import 'package:i_wanna_eat/core/di/injector.dart';
import 'package:i_wanna_eat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:i_wanna_eat/features/profile/presentation/cubit/profile_cubit.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadAllergies(),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatefulWidget {
  const _ProfileSetupView();

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final _firstNameController = TextEditingController();
  final _dietController = TextEditingController();
  final _customAllergyController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _dietController.dispose();
    _customAllergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (prev, current) => prev.errorMessage != current.errorMessage || prev.isSaved != current.isSaved,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<ProfileCubit>().clearMessage();
        }
        if (state.isSaved) {
          context.read<AuthCubit>().markProfileCompleted();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Настройка профиля'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return BlocBuilder<ConnectivityCubit, bool>(
                builder: (context, isOnline) {
                  final canSave = isOnline && !profileState.isSaving;

                  if (profileState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      const Text(
                        'Аллергии',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profileState.allergies
                            .map(
                              (allergy) => FilterChip(
                                label: Text(allergy.name),
                                selected: profileState.selectedAllergyIds.contains(allergy.id),
                                onSelected: (_) => context.read<ProfileCubit>().toggleAllergy(allergy.id),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customAllergyController,
                              decoration: const InputDecoration(
                                labelText: 'Добавить свой аллерген',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              context.read<ProfileCubit>().addCustomAllergy(_customAllergyController.text);
                              _customAllergyController.clear();
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      if (profileState.customAllergies.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacing8),
                        Wrap(
                          spacing: 8,
                          children: profileState.customAllergies
                              .map(
                                (item) => Chip(
                                  label: Text(item),
                                  onDeleted: () => context.read<ProfileCubit>().removeCustomAllergy(item),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: AppConstants.spacing16),
                      TextField(
                        controller: _dietController,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Диета',
                          hintText: 'Например: не ем сахар, придерживаюсь кето-диеты...',
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing24),
                      ElevatedButton(
                        onPressed: canSave
                            ? () {
                                context.read<ProfileCubit>().saveProfile(
                                      firstName: _firstNameController.text.trim(),
                                      dietDescription: _dietController.text.trim(),
                                    );
                              }
                            : null,
                        child: profileState.isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Сохранить'),
                      ),
                    ],
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

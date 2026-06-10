import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_wanna_eat/core/error/failure.dart';
import 'package:i_wanna_eat/features/profile/domain/entities/allergy.dart';
import 'package:i_wanna_eat/features/profile/domain/usecases/get_allergies_usecase.dart';
import 'package:i_wanna_eat/features/profile/domain/usecases/update_allergies_usecase.dart';
import 'package:i_wanna_eat/features/profile/domain/usecases/update_profile_usecase.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
    this.allergies = const [],
    this.selectedAllergyIds = const {},
    this.customAllergies = const [],
  });

  final bool isLoading;
  final bool isSaving;
  final bool isSaved;
  final String? errorMessage;
  final List<Allergy> allergies;
  final Set<int> selectedAllergyIds;
  final List<String> customAllergies;

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSaved,
    String? errorMessage,
    bool clearMessage = false,
    List<Allergy>? allergies,
    Set<int>? selectedAllergyIds,
    List<String>? customAllergies,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
      allergies: allergies ?? this.allergies,
      selectedAllergyIds: selectedAllergyIds ?? this.selectedAllergyIds,
      customAllergies: customAllergies ?? this.customAllergies,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        isSaved,
        errorMessage,
        allergies,
        selectedAllergyIds,
        customAllergies,
      ];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetAllergiesUseCase getAllergiesUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdateAllergiesUseCase updateAllergiesUseCase,
  })  : _getAllergiesUseCase = getAllergiesUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updateAllergiesUseCase = updateAllergiesUseCase,
        super(const ProfileState());

  final GetAllergiesUseCase _getAllergiesUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateAllergiesUseCase _updateAllergiesUseCase;

  Future<void> loadAllergies() async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    try {
      final allergies = await _getAllergiesUseCase();
      emit(state.copyWith(isLoading: false, allergies: allergies));
    } on AppFailure catch (failure) {
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Не удалось загрузить аллергены'));
    }
  }

  void toggleAllergy(int id) {
    final updated = {...state.selectedAllergyIds};
    if (!updated.add(id)) {
      updated.remove(id);
    }
    emit(state.copyWith(selectedAllergyIds: updated));
  }

  void addCustomAllergy(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final updated = [...state.customAllergies, trimmed];
    emit(state.copyWith(customAllergies: updated));
  }

  void removeCustomAllergy(String name) {
    final updated = [...state.customAllergies]..remove(name);
    emit(state.copyWith(customAllergies: updated));
  }

  Future<void> saveProfile({
    required String firstName,
    required String dietDescription,
  }) async {
    emit(state.copyWith(isSaving: true, clearMessage: true, isSaved: false));
    try {
      await _updateProfileUseCase(
        firstName: firstName,
        dietDescription: dietDescription,
      );
      await _updateAllergiesUseCase(
        allergyIds: state.selectedAllergyIds.toList(),
        customAllergies: state.customAllergies,
      );
      emit(state.copyWith(isSaving: false, isSaved: true));
    } on AppFailure catch (failure) {
      emit(state.copyWith(isSaving: false, errorMessage: failure.message));
    } catch (_) {
      emit(state.copyWith(isSaving: false, errorMessage: 'Не удалось сохранить профиль'));
    }
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }
}

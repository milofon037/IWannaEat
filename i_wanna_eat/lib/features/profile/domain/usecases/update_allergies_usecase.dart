import 'package:i_wanna_eat/features/profile/domain/entities/profile.dart';
import 'package:i_wanna_eat/features/profile/domain/repositories/profile_repository.dart';

class UpdateAllergiesUseCase {
  UpdateAllergiesUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call({
    required List<int> allergyIds,
    required List<String> customAllergies,
  }) {
    return _repository.updateAllergies(
      allergyIds: allergyIds,
      customAllergies: customAllergies,
    );
  }
}

import 'package:i_wanna_eat/features/profile/domain/entities/profile.dart';
import 'package:i_wanna_eat/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call({
    required String firstName,
    required String dietDescription,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      dietDescription: dietDescription,
    );
  }
}

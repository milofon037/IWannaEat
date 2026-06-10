import 'package:i_wanna_eat/features/profile/domain/entities/allergy.dart';
import 'package:i_wanna_eat/features/profile/domain/repositories/profile_repository.dart';

class GetAllergiesUseCase {
  GetAllergiesUseCase(this._repository);

  final ProfileRepository _repository;

  Future<List<Allergy>> call() => _repository.getAllergies();
}

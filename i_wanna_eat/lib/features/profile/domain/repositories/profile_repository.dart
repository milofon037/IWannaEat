import 'package:i_wanna_eat/features/profile/domain/entities/allergy.dart';
import 'package:i_wanna_eat/features/profile/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile> getProfile();
  Future<Profile> updateProfile({
    required String firstName,
    required String dietDescription,
  });

  Future<List<Allergy>> getAllergies();

  Future<Profile> updateAllergies({
    required List<int> allergyIds,
    required List<String> customAllergies,
  });
}

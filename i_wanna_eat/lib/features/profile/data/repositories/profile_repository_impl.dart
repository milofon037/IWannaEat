import 'package:dio/dio.dart';
import 'package:i_wanna_eat/core/error/failure.dart';
import 'package:i_wanna_eat/features/profile/data/datasources/profile_api.dart';
import 'package:i_wanna_eat/features/profile/domain/entities/allergy.dart';
import 'package:i_wanna_eat/features/profile/domain/entities/profile.dart';
import 'package:i_wanna_eat/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._profileApi);

  final ProfileApi _profileApi;

  @override
  Future<List<Allergy>> getAllergies() async {
    try {
      final data = await _profileApi.getAllergies();
      return data.map((e) => e.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Profile> getProfile() async {
    try {
      final data = await _profileApi.getProfile();
      return data.toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Profile> updateAllergies({
    required List<int> allergyIds,
    required List<String> customAllergies,
  }) async {
    try {
      final data = await _profileApi.updateAllergies(
        allergyIds: allergyIds,
        customAllergies: customAllergies,
      );
      return data.toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Profile> updateProfile({
    required String firstName,
    required String dietDescription,
  }) async {
    try {
      final data = await _profileApi.updateProfile(
        firstName: firstName,
        dietDescription: dietDescription,
      );
      return data.toEntity();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

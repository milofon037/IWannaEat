import 'package:dio/dio.dart';
import 'package:i_wanna_eat/features/profile/data/models/allergy_dto.dart';
import 'package:i_wanna_eat/features/profile/data/models/profile_dto.dart';

class ProfileApi {
  ProfileApi(this._dio);

  final Dio _dio;

  Future<ProfileDto> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/profile');
    return ProfileDto.fromJson(response.data!);
  }

  Future<ProfileDto> updateProfile({
    required String firstName,
    required String dietDescription,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/profile',
      data: {
        'firstName': firstName,
        'dietDescription': dietDescription,
      },
    );
    return ProfileDto.fromJson(response.data!);
  }

  Future<List<AllergyDto>> getAllergies() async {
    final response = await _dio.get<List<dynamic>>('/api/allergies');
    final data = response.data ?? const [];
    return data.map((e) => AllergyDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProfileDto> updateAllergies({
    required List<int> allergyIds,
    required List<String> customAllergies,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/profile/allergies',
      data: {
        'allergyIds': allergyIds,
        'customAllergies': customAllergies,
      },
    );
    return ProfileDto.fromJson(response.data!);
  }
}

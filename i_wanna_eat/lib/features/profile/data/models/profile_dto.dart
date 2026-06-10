import 'package:i_wanna_eat/features/profile/data/models/allergy_dto.dart';
import 'package:i_wanna_eat/features/profile/domain/entities/profile.dart';

class ProfileDto {
  const ProfileDto({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.dietDescription,
    required this.allergies,
  });

  final String userId;
  final String email;
  final String firstName;
  final String dietDescription;
  final List<AllergyDto> allergies;

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    final allergyList = (json['allergies'] as List<dynamic>? ?? const [])
        .map((item) => AllergyDto.fromJson(item as Map<String, dynamic>))
        .toList();
    return ProfileDto(
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      dietDescription: json['dietDescription'] as String? ?? '',
      allergies: allergyList,
    );
  }

  Profile toEntity() => Profile(
        userId: userId,
        email: email,
        firstName: firstName,
        dietDescription: dietDescription,
        allergies: allergies.map((e) => e.toEntity()).toList(),
      );
}

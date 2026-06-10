import 'package:i_wanna_eat/features/profile/domain/entities/allergy.dart';

class AllergyDto {
  const AllergyDto({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory AllergyDto.fromJson(Map<String, dynamic> json) {
    return AllergyDto(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Allergy toEntity() => Allergy(id: id, name: name);
}

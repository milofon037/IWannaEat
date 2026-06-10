import 'package:i_wanna_eat/features/profile/domain/entities/allergy.dart';

class Profile {
  const Profile({
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
  final List<Allergy> allergies;
}

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;

  const UserEntity({
    required this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        firstName,
        lastName,
        displayName,
        photoUrl,
        isEmailVerified,
      ];
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.firstName,
    super.lastName,
    super.displayName,
    super.photoUrl,
    super.isEmailVerified = false,
  });

  /// Builds a [UserModel] from a Supabase [User].
  ///
  /// Profile fields (firstName, lastName, displayName, photoUrl) aren't
  /// native Supabase columns — they live in `user.userMetadata`, populated
  /// either at sign-up (`data:` param) or later via `updateUser`/your
  /// `profiles` table. If a field isn't in metadata yet, it comes back null.
  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    return UserModel(
      uid: user.id,
      email: user.email,
      firstName: metadata['first_name'] as String?,
      lastName: metadata['last_name'] as String?,
      displayName: metadata['display_name'] as String?,
      photoUrl: metadata['photo_url'] as String?,
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isEmailVerified': isEmailVerified,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }
}
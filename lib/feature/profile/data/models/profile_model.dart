import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    super.username,
    super.fullName,
    super.bio,
    super.website,
    super.location,
    super.avatarUrl,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        userId: json['user_id'] as String,
        username: json['username'] as String?,
        fullName: json['full_name'] as String?,
        bio: json['bio'] as String?,
        website: json['website'] as String?,
        location: json['location'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
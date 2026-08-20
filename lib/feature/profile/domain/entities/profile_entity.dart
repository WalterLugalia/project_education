class ProfileEntity {
  final String userId;
  final String? username;
  final String? fullName;
  final String? bio;
  final String? website;
  final String? location;
  final String? avatarUrl;
  final DateTime createdAt;

  const ProfileEntity({
    required this.userId,
    this.username,
    this.fullName,
    this.bio,
    this.website,
    this.location,
    this.avatarUrl,
    required this.createdAt,
  });
}
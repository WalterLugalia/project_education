import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_stats_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final ProfileStatsEntity stats;
  final String? userEmail;
  final DateTime? joinedAt;
  final bool isSaving;
  final bool? usernameAvailable;

  const ProfileLoaded({
    required this.profile,
    required this.stats,
    required this.userEmail,
    required this.joinedAt,
    this.isSaving = false,
    this.usernameAvailable,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    bool? isSaving,
    bool? usernameAvailable,
    bool clearUsernameAvailable = false,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      stats: stats,
      userEmail: userEmail,
      joinedAt: joinedAt,
      isSaving: isSaving ?? this.isSaving,
      usernameAvailable: clearUsernameAvailable ? null : (usernameAvailable ?? this.usernameAvailable),
    );
  }

  @override
  List<Object?> get props => [profile, stats, userEmail, joinedAt, isSaving, usernameAvailable];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
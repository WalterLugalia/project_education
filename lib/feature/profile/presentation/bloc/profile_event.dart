import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileAvatarChangeRequested extends ProfileEvent {
  final String filePath;
  const ProfileAvatarChangeRequested(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

class ProfileUsernameCheckRequested extends ProfileEvent {
  final String username;
  const ProfileUsernameCheckRequested(this.username);
  @override
  List<Object?> get props => [username];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? fullName;
  final String? username;
  final String? bio;
  final String? website;
  final String? location;

  const ProfileUpdateRequested({this.fullName, this.username, this.bio, this.website, this.location});

  @override
  List<Object?> get props => [fullName, username, bio, website, location];
}
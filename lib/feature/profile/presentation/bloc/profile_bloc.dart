import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../domain/usecase/get_profile_usecase.dart';
import '../../domain/usecase/get_profile_stats_usecase.dart';
import '../../domain/usecase/update_profile_usecase.dart';
import '../../domain/usecase/upload_avatar_usecase.dart';
import '../../domain/usecase/check_username_available_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final GetProfileStatsUseCase getProfileStatsUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final CheckUsernameAvailableUseCase checkUsernameAvailableUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.getProfileStatsUseCase,
    required this.updateProfileUseCase,
    required this.uploadAvatarUseCase,
    required this.checkUsernameAvailableUseCase,
  }) : super(ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileAvatarChangeRequested>(_onAvatarChanged);
    on<ProfileUsernameCheckRequested>(_onUsernameCheck);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  Future<void> _onStarted(ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profile = await getProfileUseCase();
      if (profile == null) {
        emit(const ProfileError('Sign in to view your profile.'));
        return;
      }
      final stats = await getProfileStatsUseCase();
      final user = Supabase.instance.client.auth.currentUser;

      emit(ProfileLoaded(
        profile: profile,
        stats: stats,
        userEmail: user?.email,
        joinedAt: user?.createdAt != null ? DateTime.tryParse(user!.createdAt) : null,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAvatarChanged(ProfileAvatarChangeRequested event, Emitter<ProfileState> emit) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isSaving: true));
    try {
      await uploadAvatarUseCase(event.filePath);
      add(const ProfileStarted());
    } catch (_) {
      emit(current.copyWith(isSaving: false));
    }
  }

  Future<void> _onUsernameCheck(ProfileUsernameCheckRequested event, Emitter<ProfileState> emit) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    if (event.username.trim().isEmpty) {
      emit(current.copyWith(clearUsernameAvailable: true));
      return;
    }

    final available = await checkUsernameAvailableUseCase(event.username.trim());
    emit(current.copyWith(usernameAvailable: available));
  }

  Future<void> _onUpdateRequested(ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isSaving: true));
    try {
      await updateProfileUseCase(
        fullName: event.fullName,
        username: event.username,
        bio: event.bio,
        website: event.website,
        location: event.location,
      );
      add(const ProfileStarted());
    } catch (e) {
      emit(current.copyWith(isSaving: false));
    }
  }
}
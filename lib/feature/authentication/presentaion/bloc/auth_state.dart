import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AppAuthState extends Equatable {
  const AppAuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AppAuthState {}

class AuthLoading extends AppAuthState {}

class AuthSuccess extends AppAuthState {
  final UserEntity user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Sign-in specifically failed because Supabase reported the account's
/// email as unconfirmed (distinct from wrong password / other errors).
class AuthEmailNotVerified extends AppAuthState {
  final String email;
  const AuthEmailNotVerified(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthFailure extends AppAuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Email verification polling (Check Your Email screen) ---

class EmailVerificationChecking extends AppAuthState {}

class EmailVerificationConfirmed extends AppAuthState {}

class EmailVerificationStillPending extends AppAuthState {}

class EmailVerificationOffline extends AppAuthState {}

class EmailVerificationCheckError extends AppAuthState {
  final String message;
  const EmailVerificationCheckError(this.message);

  @override
  List<Object?> get props => [message];
}

class VerificationEmailResent extends AppAuthState {}

// --- Password reset / change ---

class PasswordResetEmailSent extends AppAuthState {}

class PasswordUpdated extends AppAuthState {}
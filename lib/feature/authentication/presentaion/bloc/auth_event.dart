import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

class CheckEmailVerificationRequested extends AuthEvent {
  const CheckEmailVerificationRequested();
}

class ResendVerificationRequested extends AuthEvent {
  final String email;

  const ResendVerificationRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String newPassword;

  const ResetPasswordRequested({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

class ChangePasswordRequested extends AuthEvent {
  final String newPassword;

  const ChangePasswordRequested({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
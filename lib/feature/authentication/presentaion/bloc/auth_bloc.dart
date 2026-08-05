import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/authentication/domain/usecase/check_email_verified_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/resend_verification_email_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/send_password_reset_email_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/sign_in_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/sign_out_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/sign_up_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/update_password_usecase.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_event.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';




class AuthBloc extends Bloc<AuthEvent, AppAuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final ResendVerificationEmailUseCase resendVerificationEmailUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final CheckEmailVerifiedUseCase checkEmailVerifiedUseCase;
  final SignOutUseCase signOutUseCase;

  /// Set by the sign-up flow so "Check Your Email" / resend know which
  /// address to act on without needing it passed through every event.
  String? pendingVerificationEmail;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.resendVerificationEmailUseCase,
    required this.sendPasswordResetEmailUseCase,
    required this.updatePasswordUseCase,
    required this.checkEmailVerifiedUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<CheckEmailVerificationRequested>(_onCheckEmailVerificationRequested);
    on<ResendVerificationRequested>(_onResendVerificationRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signInUseCase(email: event.email, password: event.password);
      emit(AuthSuccess(user));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        emit(AuthEmailNotVerified(event.email));
      } else {
        emit(AuthFailure(e.message));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      pendingVerificationEmail = event.email;
      emit(AuthSuccess(user));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCheckEmailVerificationRequested(
    CheckEmailVerificationRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(EmailVerificationChecking());
    try {
      final user = await checkEmailVerifiedUseCase();
      if (user.isEmailVerified) {
        emit(EmailVerificationConfirmed());
      } else {
        emit(EmailVerificationStillPending());
      }
    } on SocketException {
      emit(EmailVerificationOffline());
    } on AuthException catch (e) {
      emit(EmailVerificationCheckError(e.message));
    } catch (e) {
      final message = e.toString();
      if (message.contains('SocketException') || message.contains('Failed host lookup')) {
        emit(EmailVerificationOffline());
      } else {
        emit(EmailVerificationCheckError(message));
      }
    }
  }

  Future<void> _onResendVerificationRequested(
    ResendVerificationRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    try {
      await resendVerificationEmailUseCase(email: event.email);
      emit(VerificationEmailResent());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await sendPasswordResetEmailUseCase(email: event.email);
    } catch (_) {
      // Intentionally swallowed: always show the generic "if an account
      // exists" message regardless of outcome, so we don't leak which
      // emails are registered.
    }
    emit(PasswordResetEmailSent());
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await updatePasswordUseCase(newPassword: event.newPassword);
      emit(PasswordUpdated());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await updatePasswordUseCase(newPassword: event.newPassword);
      emit(PasswordUpdated());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    await signOutUseCase();
    emit(AuthInitial());
  }
}
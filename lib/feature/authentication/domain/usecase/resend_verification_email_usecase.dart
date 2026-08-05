import '../repositories/auth_repository.dart';

class ResendVerificationEmailUseCase {
  final AuthRepository repository;

  const ResendVerificationEmailUseCase(this.repository);

  Future<void> call({required String email}) {
    return repository.resendVerificationEmail(email: email);
  }
}
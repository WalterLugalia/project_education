import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  const SendPasswordResetEmailUseCase(this.repository);

  Future<void> call({required String email}) {
    return repository.sendPasswordResetEmail(email: email);
  }
}
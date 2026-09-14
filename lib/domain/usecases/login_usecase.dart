import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<AuthSessionEntity> call({
    required String phoneNumber,
    required String password,
  }) {
    return _repository.login(phoneNumber: phoneNumber, password: password);
  }
}

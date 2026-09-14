import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<UserEntity> call() {
    return _repository.getCurrentUser();
  }
}

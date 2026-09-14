import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    UserRole role = UserRole.collector,
    UserAddressEntity? address,
    String? profilePicturePath,
  }) {
    return _repository.register(
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      email: email,
      role: role,
      address: address,
      profilePicturePath: profilePicturePath,
    );
  }
}

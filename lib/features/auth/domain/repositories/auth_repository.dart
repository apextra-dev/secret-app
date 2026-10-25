import 'package:secret/features/auth/domain/entities/username_entity.dart';

abstract class AuthRepository {
  Future<void> createUser(String name, String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<UsernameEntity> checkUniqueness(String username);
  Future<void> changeUserInfo(
    String name,
    String oldUsername,
    String newUsername,
  );
}

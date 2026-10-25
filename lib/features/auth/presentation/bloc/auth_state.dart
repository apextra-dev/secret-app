abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccessful extends AuthState {}

class AuthFailure extends AuthState {
  String message;

  AuthFailure({required this.message});
}

class UsernameIsChecking extends AuthState {}

class UsernameUnique extends AuthState {
  String username;
  bool uniqueness;

  UsernameUnique({required this.username, required this.uniqueness});
}

class UsernameIsNotUnique extends AuthState {
  bool uniqueness;

  UsernameIsNotUnique({required this.uniqueness});
}

class UsernameFailure extends AuthState {
  String message;

  UsernameFailure({required this.message});
}

class ProfileInfoChanged extends AuthState {}
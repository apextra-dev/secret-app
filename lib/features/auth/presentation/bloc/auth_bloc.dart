import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret/features/auth/domain/repositories/auth_repository.dart';
import 'package:secret/features/auth/presentation/bloc/auth_event.dart';
import 'package:secret/features/auth/presentation/bloc/auth_state.dart';
import 'package:stream_transform/stream_transform.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<CreateUser>((event, emit) async {
      try {
        emit(AuthLoading());

        await repository.createUser(event.name, event.email, event.password);

        emit(AuthSuccessful());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<SignOutUser>((event, emit) async {
      try {
        await repository.signOut();
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<SignInUser>((event, emit) async {
      try {
        emit(AuthLoading());

        await repository.signIn(event.email, event.password);
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<OnTypingChanged>(
      (event, emit) async {
        try {
          final text = event.text.trim().toLowerCase();

          if (text.isEmpty || text.length < 3) {
            return;
          }

          final regExp = RegExp('^[a-zA-Z0-9_]+\$');
          if (!regExp.hasMatch(text)) {
            emit(UsernameFailure(message: "Invalid symbols"));
            return;
          }

          emit(UsernameIsChecking());

          final response = await repository.checkUniqueness(text);

          if (!response.isUnique) {
            emit(UsernameIsNotUnique(uniqueness: response.isUnique));
          } else {
            emit(
              UsernameUnique(
                username: response.username,
                uniqueness: response.isUnique,
              ),
            );
          }
        } catch (e) {
          emit(UsernameFailure(message: e.toString()));
        }
      },
      transformer: (events, mapper) {
        return restartable<OnTypingChanged>()(
          events.debounce(const Duration(milliseconds: 500)),
          mapper,
        );
      },
    );
    on<ChangeProfileInfo>((event, emit) async {
      try {
        await repository.changeUserInfo(
          event.name,
          event.oldUsername,
          event.newUsername,
        );
        emit(ProfileInfoChanged());
      } catch (e) {
        throw '$e';
      }
    });
  }
}

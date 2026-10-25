import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:secret/core/service/auth_service.dart';
import 'package:secret/features/auth/domain/repositories/auth_repository.dart';
import 'package:secret/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:secret/features/auth/presentation/bloc/auth_event.dart';
import 'package:secret/features/auth/presentation/bloc/auth_state.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _authService = GetIt.I<AuthService>();

    return BlocProvider(
      create: (context) => AuthBloc(GetIt.I<AuthRepository>()),
      child: Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset(
            isDark
                ? 'assets/images/auth/darkTheme.svg'
                : 'assets/images/auth/lightTheme.svg',
            width: 55,
            height: 55,
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isUnique = state is UsernameUnique;
                        final isChecking = state is UsernameIsChecking;
                        final isFailure = state is UsernameFailure;
                        final isNotUnique = state is UsernameIsNotUnique;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Enter your username',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                            const SizedBox(height: 60),
                            TextField(
                              controller: _controller,
                              onChanged: (text) {
                                context.read<AuthBloc>().add(
                                  OnTypingChanged(text: text),
                                );
                              },
                              decoration: InputDecoration(
                                prefixText: '@',
                                hintText: 'username',
                                filled: true,
                                suffixIcon: isChecking
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : isUnique
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : null,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isNotUnique || isFailure
                                        ? Colors.red
                                        : isDark
                                        ? Colors.transparent
                                        : Colors.black12,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isUnique
                                        ? Colors.green
                                        : isNotUnique || isFailure
                                        ? Colors.red
                                        : Theme.of(context).primaryColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 24,
                              child: Builder(
                                builder: (context) {
                                  if (isNotUnique) {
                                    return Text(
                                      'Username ${_controller.text.trim()} is not available',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    );
                                  }
                                  if (isFailure) {
                                    return Text(
                                      state.message,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    );
                                  }
                                  if (isUnique) {
                                    return const Text(
                                      'Username is available!',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 13,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isUnique
                                    ? () {
                                        _authService.saveUsername(
                                          _controller.text.trim(),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Continue'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

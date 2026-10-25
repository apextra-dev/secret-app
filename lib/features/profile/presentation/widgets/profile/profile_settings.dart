import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:secret/features/auth/domain/repositories/auth_repository.dart';
import 'package:secret/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:secret/features/auth/presentation/bloc/auth_event.dart';
import 'package:secret/features/auth/presentation/bloc/auth_state.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({
    super.key,
    required this.name,
    required this.username,
  });

  final name;
  final username;

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    _usernameController.text = widget.username!;
    _nameController.text = widget.name!;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _showEditDialog(BuildContext screenContext) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocBuilder<AuthBloc, AuthState>(
              bloc: screenContext.read<AuthBloc>(),
              builder: (context, state) {
                final currentUsername = _usernameController.text.trim();
                final currentName = _nameController.text.trim();

                final isChecking = state is UsernameIsChecking;
                final isFailure = state is UsernameFailure;
                final isNotUnique = state is UsernameIsNotUnique;

                final isUnique =
                    state is UsernameUnique &&
                    currentUsername.isNotEmpty &&
                    currentUsername.length >= 3 &&
                    state.username == currentUsername;

                final hasChanges =
                    currentName != widget.name ||
                    currentUsername != widget.username;

                final isNameNotEmpty = currentName.isNotEmpty;
                final isUsernameNotEmpty = currentUsername.isNotEmpty;
                final isUsernameLengthValid = currentUsername.length >= 3;

                final isUsernameValid =
                    currentUsername == widget.username ||
                    (isUnique && isUsernameNotEmpty && isUsernameLengthValid);

                final isCanApply =
                    hasChanges &&
                    isNameNotEmpty &&
                    isUsernameValid &&
                    !isChecking;

                return BlocProvider(
                  create: (context) => AuthBloc(GetIt.I<AuthRepository>()),
                  child: AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mode_edit_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Edit profile info',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 4),
                            TextField(
                              controller: _nameController,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Your name',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _usernameController,
                              onChanged: (text) {
                                setDialogState(() {});
                                if (text.trim() != widget.username) {
                                  screenContext.read<AuthBloc>().add(
                                    OnTypingChanged(text: text),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                prefixText: '@ ',
                                labelText: 'Username',
                                prefixIcon: const Icon(
                                  Icons.alternate_email_rounded,
                                ),
                                suffixIcon: isChecking
                                    ? const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : currentUsername != widget.username &&
                                          isUnique
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color:
                                        currentUsername != widget.username &&
                                            (isNotUnique ||
                                                isFailure ||
                                                (!isChecking &&
                                                    currentUsername
                                                        .isNotEmpty &&
                                                    currentUsername.length < 3))
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color:
                                        currentUsername != widget.username &&
                                            isUnique
                                        ? Colors.green
                                        : currentUsername != widget.username &&
                                              (isNotUnique ||
                                                  isFailure ||
                                                  (!isChecking &&
                                                      currentUsername
                                                          .isNotEmpty &&
                                                      currentUsername.length <
                                                          3))
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            if (currentUsername != widget.username &&
                                isUsernameNotEmpty) ...[
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 20,
                                child: Builder(
                                  builder: (context) {
                                    if (currentUsername.length < 3) {
                                      return const Text(
                                        'Minimum 3 characters required',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    if (isNotUnique) {
                                      return const Text(
                                        'This username is already taken',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    if (isFailure) {
                                      return Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    if (isUnique) {
                                      return const Text(
                                        'Username is available!',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    actionsPadding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 24,
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (buttonContext) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: isCanApply
                                      ? () {
                                          buttonContext.read<AuthBloc>().add(
                                            ChangeProfileInfo(
                                              name: _nameController.text.trim(),
                                              oldUsername: widget.username,
                                              newUsername: _usernameController.text
                                                  .trim(),
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                        }
                                      : null,
                                  child: const Text('Apply'),
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 70,
            child: Text(
              widget.name[0].toString().toUpperCase(),
              style: TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 37, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.edit),
                      const SizedBox(height: 5),
                      Text(
                        'Edit Info',
                        style: TextStyle(
                          fontWeight: .w500,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/settings'),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 37, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.settings),
                      const SizedBox(height: 5),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontWeight: .w500,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

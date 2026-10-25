import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:secret/core/service/auth_service.dart';
import 'package:secret/features/auth/domain/repositories/auth_repository.dart';
import 'package:secret/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:secret/features/profile/presentation/widgets/profile/profile_alert_dialog.dart';
import 'package:secret/features/profile/presentation/widgets/profile/profile_settings.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.name});

  final name;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final _authService = GetIt.I<AuthService>();
    final username = _authService.username;

    return BlocProvider(
      create: (_) => AuthBloc(GetIt.I<AuthRepository>()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            Builder(
              builder: (newContext) {
                return IconButton(
                  onPressed: () {
                    showDialog(
                      context: newContext,
                      builder: (dialogContext) {
                        return ProfileAlertDialog(parentContext: newContext);
                      },
                    );
                  },
                  icon: Icon(Icons.exit_to_app),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              ProfileSettings(name: widget.name, username: username.toString()),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: '@$username'),
                            );
                          },
                          child: Text(
                            '@$username',
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              decorationColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Username',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

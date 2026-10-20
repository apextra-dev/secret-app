import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:secret/features/auth/presentation/bloc/auth_event.dart';

class ProfileAlertDialog extends StatefulWidget {
  const ProfileAlertDialog({required this.parentContext, super.key});

  final BuildContext parentContext;

  @override
  State<ProfileAlertDialog> createState() => _ProfileAlertDialogState();
}

class _ProfileAlertDialogState extends State<ProfileAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Sign Out',)),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.parentContext.read<AuthBloc>().add(SignOutUser());
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cance'),
            ),
          ],
        ),
      ],
    );
  }
}

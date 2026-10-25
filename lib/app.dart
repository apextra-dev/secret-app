import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret/bloc/theme/theme_cubit.dart';
import 'package:secret/config/routes/app_router.dart';
import 'package:secret/config/theme/app_theme.dart';
class SecretApp extends StatelessWidget {
  const SecretApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final currentThemeMode = state.brightness == Brightness.dark 
            ? ThemeMode.dark 
            : ThemeMode.light;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          
          themeMode: currentThemeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
        );
      },
    );
  }
}


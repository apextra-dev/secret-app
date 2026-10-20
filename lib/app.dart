import 'package:flutter/material.dart';
import 'package:secret/config/routes/app_router.dart';
import 'package:secret/config/theme/app_theme.dart';
class SecretApp extends StatelessWidget {
  const SecretApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: lightTheme,
    );
  }
}

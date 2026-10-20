import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.white,
    primary: Colors.white,
    onPrimary: Colors.black,
    surfaceContainer: const Color(0xFF3B3B3B),
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome
  ),
  scaffoldBackgroundColor: const Color(0xFF202020),
  textTheme: textTheme,
  useMaterial3: true,
);
final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: Colors.black,
    primary: Colors.black,
    onPrimary: Colors.white,
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome
  ),
  appBarTheme: AppBarTheme(backgroundColor: Color(0x33525252),),
  scaffoldBackgroundColor: const Color(0xFFD7D7D7),
  textTheme: textTheme,
  useMaterial3: true,
);

final textTheme = const TextTheme(
  titleMedium: TextStyle(fontSize: 18, fontWeight: .w600),
  titleLarge: TextStyle(fontSize: 22, fontWeight: .w600),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: .w400),
);

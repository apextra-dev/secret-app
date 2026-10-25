import 'package:flutter/material.dart';

const _customTextTheme = TextTheme(
  displayMedium: TextStyle(fontSize: 50, fontFamily: 'Rajdhani-Regular'),
  displaySmall: TextStyle(fontSize: 36, fontFamily: 'Rajdhani-Regular'),
  titleMedium: TextStyle(fontSize: 18, fontWeight: .w600),
  titleLarge: TextStyle(fontSize: 22, fontWeight: .w600),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: .w400),
  bodySmall: TextStyle(fontSize: 14, fontWeight: .w400, color: Color.fromARGB(255, 155, 154, 154)),
  labelMedium: TextStyle(fontSize: 10),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF202020),
  textTheme: _customTextTheme,
  
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.white,
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: const Color(0xFF3B3B3B),
    onSecondary: Colors.white,
    surfaceContainer: const Color(0xFF2C2C2E), 
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
  ),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF1F1F1),
  textTheme: _customTextTheme,
  
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: Colors.black,
    primary: Colors.black,   
    onPrimary: Colors.white,  
    secondary: const Color(0xFFE5E5EA),
    onSecondary: Colors.black,
    surfaceContainer: const Color(0xFFF2F2F7), 
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
  ),
);

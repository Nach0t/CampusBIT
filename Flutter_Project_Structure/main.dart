// Placeholder for main.dart

import 'package:flutter/material.dart';
import 'android/user/login_screen.dart'; // Ajuste para la nueva estructura

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Bit App',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF71679C),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 5.0,
          ),
        ),
      ),
      home: LoginScreen(), // Ajuste para que el punto de inicio sea la pantalla de inicio de sesión
    );
  }
}

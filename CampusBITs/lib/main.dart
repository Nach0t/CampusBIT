import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  // No necesitas inicializar `sqflite` o `ffi` para web.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Bit App',
      debugShowCheckedModeBanner: false,
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
            backgroundColor: Color(0xFF87CEEB),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 5.0,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4682B4),
          titleTextStyle: TextStyle(
            fontFamily: 'Exo2',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

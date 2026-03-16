import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor:  Color.fromARGB(255, 22, 27, 50),
      primaryColor: Colors.blueGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 22, 27, 50),
      ),
    );
  }
}

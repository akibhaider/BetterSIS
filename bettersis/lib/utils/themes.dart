import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme(String dept) {
    switch (dept.toLowerCase()) {
      case 'cse':
        return ThemeData(
          primaryColor: Colors.blue,
          secondaryHeaderColor: const Color.fromARGB(255, 6, 94, 179), 
        );
      case 'eee':
        return ThemeData(
          primaryColor: Colors.amber,
          secondaryHeaderColor: const Color.fromARGB(255, 255, 183, 77),
        );
      case 'mpe':
        return ThemeData(
          primaryColor: Colors.red,
          secondaryHeaderColor: const Color.fromARGB(255, 200, 0, 0), 
        );
      case 'btm':
        return ThemeData(
          primaryColor: Colors.purple,
          secondaryHeaderColor: const Color.fromARGB(255, 123, 58, 186), 
        );
      case 'cee':
        return ThemeData(
          primaryColor: Colors.green,
          secondaryHeaderColor: const Color.fromARGB(255, 102, 175, 50),
        );
      case 'admin':
        return ThemeData(
          primaryColor: const Color(0xFF1F1C2C),
          secondaryHeaderColor: const Color(0x102542),
        );
      default:
        // Default theme if no department matches
        return ThemeData(
          primaryColor: Colors.grey,
          secondaryHeaderColor: Colors.blueGrey, 
        );
    }
  }
}

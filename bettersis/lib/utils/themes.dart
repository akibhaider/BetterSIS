import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme(String dept) {
    switch (dept.toLowerCase()) {
      case 'cse':
        return ThemeData(
          primaryColor: Colors.blue,
          secondaryHeaderColor: const Color.fromARGB(255, 6, 55, 139),
        );
      case 'eee':
        return ThemeData(
          primaryColor: Colors.amber,
          secondaryHeaderColor: const Color.fromARGB(240, 255, 217, 101),
        );
      case 'mpe':
        return ThemeData(
          primaryColor: Colors.red,
          secondaryHeaderColor: const Color.fromARGB(255, 155, 0, 0),
        );
      case 'btm':
        return ThemeData(
          primaryColor: Colors.purple,
          secondaryHeaderColor: const Color.fromARGB(255, 74, 22, 164),
        );
      case 'cee':
        return ThemeData(
          primaryColor: Colors.green,
          secondaryHeaderColor: const Color.fromARGB(255, 65, 121, 0),
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

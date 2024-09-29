import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme(String dept) {
    switch (dept.toLowerCase()) {
      case 'cse':
        return ThemeData(
          primaryColor: Colors.blue,
          secondaryHeaderColor: Colors.blueAccent,
        );
      case 'eee':
        return ThemeData(
          primaryColor: Colors.yellow,
          secondaryHeaderColor: Colors.amber,
        );
      case 'mpe':
        return ThemeData(
          primaryColor: Colors.red,
          secondaryHeaderColor: Colors.redAccent,
        );
      case 'btm':
        return ThemeData(
          primaryColor: Colors.purple,
          secondaryHeaderColor: Colors.deepPurple,
        );
      case 'cee':
        return ThemeData(
          primaryColor: Colors.green,
          secondaryHeaderColor: Colors.lightGreen,
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

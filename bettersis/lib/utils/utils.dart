import 'package:flutter/material.dart';

class Utils {
  static late Map<String, dynamic> _userData;
  static late VoidCallback _onLogout;

  static void setUser(userData) {
    _userData = userData;
  }

  static Map<String, dynamic> getUser() {
    return _userData;
  }

  static void setLogout(VoidCallback onLogout) {
    _onLogout = onLogout;
  }

  static VoidCallback getLogout() {
    return _onLogout;
  }
}

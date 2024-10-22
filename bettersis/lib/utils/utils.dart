import 'package:flutter/material.dart';

class Utils {
  static late Map<String, dynamic> _userData;
  static late VoidCallback _onLogout;
  static late String _userImageURL;

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

  static void setUserImageURL(String url){
    _userImageURL = url;
  }

  static String getUserImageURL() {
    return _userImageURL;
  }

   static String getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  static String getMonth(int number) {
    switch(number){
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Not valid month';
    }
  }

}

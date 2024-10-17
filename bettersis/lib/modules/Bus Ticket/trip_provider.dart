import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripProvider with ChangeNotifier {
  String tripDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? selectedTripType;
  Timer? _dateTimer;

  // Function to update the date at 12:00 AM automatically
  void startDateUpdater() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0);
    final duration = nextMidnight.difference(now);

    _dateTimer = Timer(duration, () {
      tripDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      notifyListeners();
      startDateUpdater(); // Restart the timer for the next day
    });
  }

  void stopDateUpdater() {
    _dateTimer?.cancel();
  }

  void selectTripType(String tripType) {
    selectedTripType = tripType;
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeatProvider with ChangeNotifier {
  final String userId;
  List<Map<String, dynamic>> seats = [];
  bool isLoading = true;

  SeatProvider(this.userId) {
    _initializeTodayDocument();
    _scheduleDailyReset();
  }

  String get _currentDateDocPath {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString();
    return 'Bus/$year/$month/$day';
  }

  Future<void> _initializeTodayDocument() async {
    await _createDailyDocument();
    fetchSeats();
  }

  Future<void> fetchSeats() async {
    isLoading = true;
    notifyListeners();

    try {
      DocumentReference dayDoc = FirebaseFirestore.instance.doc(_currentDateDocPath);
      DocumentSnapshot snapshot = await dayDoc.get();

      if (snapshot.exists && snapshot.data() != null) {
        seats = List<Map<String, dynamic>>.from((snapshot.data() as Map<String, dynamic>)['seats']);
        for (var seat in seats) {
          // Ensure each seat has a `selected` property set to false initially
          seat['selected'] = seat['selected'] ?? false;
        }
      } else {
        seats = [];
      }
    } catch (e) {
      print('Error fetching seats: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSeatSelection(int seatIndex) async {
    if (seatIndex < seats.length) {
      // Toggle the `selected` variable for visual feedback in green
      if (seats[seatIndex]['status'] == true && !seats[seatIndex]['selected']) {
        seats[seatIndex]['selected'] = true; // Mark as temporarily selected
        seats[seatIndex]['id'] = userId;
      } else if (seats[seatIndex]['selected'] && seats[seatIndex]['id'] == userId) {
        seats[seatIndex]['selected'] = false; // Deselect seat
        seats[seatIndex]['id'] = '';
      }
      notifyListeners();
    }
  }

  Future<void> confirmSelection(String userId) async {
    try {
      for (int i = 0; i < seats.length; i++) {
        if (seats[i]['selected'] == true && seats[i]['id'] == userId) {
          seats[i]['status'] = false; // Make seat unavailable
          seats[i]['selected'] = false; // Unmark selection for confirmation
        }
      }

      DocumentReference dayDoc = FirebaseFirestore.instance.doc(_currentDateDocPath);
      await dayDoc.update({'seats': seats});
      print("Seats confirmed by $userId.");
    } catch (e) {
      print('Error confirming seats: $e');
    }
    notifyListeners();
  }

  void cancelSelection() {
    for (var seat in seats) {
      if (seat['selected'] == true && seat['id'] == userId) {
        seat['selected'] = false; // Deselect the seat
        seat['status'] = true; // Mark as available again
        seat['id'] = '';
      }
    }
    notifyListeners();
  }

  int getSelectedSeatCount() {
    return seats.where((seat) => seat['selected'] == true && seat['id'] == userId).length;
  }

  void _scheduleDailyReset() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 1); // 12:01 AM
    final timeUntilMidnight = midnight.difference(now);

    Future.delayed(timeUntilMidnight, () async {
      await _createDailyDocument();
      await _resetSeats();
      _scheduleDailyReset();
    });
  }

  Future<void> _createDailyDocument() async {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString();

    final dayDocPath = 'Bus/$year/$month/$day';
    final dayDocRef = FirebaseFirestore.instance.doc(dayDocPath);

    try {
      final snapshot = await dayDocRef.get();

      if (!snapshot.exists) {
        List<Map<String, dynamic>> initialSeats = List.generate(
          40, 
          (index) => {'status': true, 'id': '', 'selected': false},
        );

        await dayDocRef.set({'seats': initialSeats});
      }
    } catch (e) {
      print("Error creating daily document: $e");
    }
  }

  Future<void> _resetSeats() async {
    try {
      DocumentReference dayDoc = FirebaseFirestore.instance.doc(_currentDateDocPath);
      List<Map<String, dynamic>> resetSeats = seats.map((seat) {
        return {'status': true, 'id': '', 'selected': false}; // Reset seat data
      }).toList();

      await dayDoc.update({'seats': resetSeats});
      seats = resetSeats;
    } catch (e) {
      print('Error resetting seats: $e');
    }
    notifyListeners();
  }

  Future<void> generateAdditionalSeats(int additionalSeatCount) async {
  try {
    // Fetch the current document reference
    DocumentReference dayDoc = FirebaseFirestore.instance.doc(_currentDateDocPath);
    DocumentSnapshot snapshot = await dayDoc.get();

    if (snapshot.exists) {
      // Fetch the existing seats
      List<Map<String, dynamic>> existingSeats = List<Map<String, dynamic>>.from(snapshot['seats'] ?? []);

      // Generate new seats and append them to the existing seats
      List<Map<String, dynamic>> newSeats = List.generate(
        additionalSeatCount,
        (index) => {'status': true, 'id': '', 'selected': false},
      );
      existingSeats.addAll(newSeats);

      // Update the Firestore document with the expanded seats array
      await dayDoc.update({'seats': existingSeats});
      seats = existingSeats; // Update the local seats list

      print("$additionalSeatCount new seats added for today's document.");
      notifyListeners();
    } else {
      print("Today's document does not exist. Please create it first.");
    }
  } catch (e) {
    print("Error generating additional seats: $e");
  }
}

}

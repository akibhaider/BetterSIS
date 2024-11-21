import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeatProvider with ChangeNotifier {
  final String userId;
  List<Map<String, dynamic>> seats = [];
  bool isLoading = true;

  // Temporary variable to store indices of seats selected by the current user
  List<int> _selectedSeatIndices = [];

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
      // Toggle selection and update status
      if (seats[seatIndex]['status'] == true && !seats[seatIndex]['selected']) {
        seats[seatIndex]['selected'] = true; // Mark as temporarily selected
        seats[seatIndex]['id'] = userId;
        _selectedSeatIndices.add(seatIndex); // Add index to the temporary list
      } else if (seats[seatIndex]['selected'] && seats[seatIndex]['id'] == userId) {
        seats[seatIndex]['selected'] = false; // Deselect seat
        seats[seatIndex]['id'] = '';
        _selectedSeatIndices.remove(seatIndex); // Remove index from the temporary list
      }
     // print("Currently selected seat indices: $_selectedSeatIndices");
      notifyListeners();
    }
  }

  Future<void> confirmSelection(String userId) async {
    try {
      for (int i = 0; i < seats.length; i++) {
        if (seats[i]['selected'] == true && seats[i]['id'] == userId) {
          seats[i]['status'] = false; // Make seat unavailable
          seats[i]['selected'] = true; // Unmark selection for confirmation
        }
      }

      DocumentReference dayDoc = FirebaseFirestore.instance.doc(_currentDateDocPath);
      await dayDoc.update({'seats': seats});
      _selectedSeatIndices.clear(); // Clear the temporary list after confirmation
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
    _selectedSeatIndices.clear(); // Clear the temporary list on cancel
    notifyListeners();
  }

  int getSelectedSeatCount() {
    return _selectedSeatIndices.length;
  }

List<int> getSelectedSeatIndices() {
  // Rebuild the selected indices from the seats list for consistency
  _selectedSeatIndices = [];
  for (int i = 0; i < seats.length; i++) {
    if (seats[i]['selected'] == true && seats[i]['id'] == userId) {
      _selectedSeatIndices.add(i);
    }
  }
  print("Currently selected seat indices: $_selectedSeatIndices");
  return List<int>.from(_selectedSeatIndices); // Return a copy of the list
}


  void _scheduleDailyReset() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 1);
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
        return {'status': true, 'id': '', 'selected': false};
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
      DocumentReference dayDoc = FirebaseFirestore.instance.doc(_currentDateDocPath);
      DocumentSnapshot snapshot = await dayDoc.get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> existingSeats = List<Map<String, dynamic>>.from(snapshot['seats'] ?? []);

        List<Map<String, dynamic>> newSeats = List.generate(
          additionalSeatCount,
          (index) => {'status': true, 'id': '', 'selected': false},
        );
        existingSeats.addAll(newSeats);

        await dayDoc.update({'seats': existingSeats});
        seats = existingSeats;

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

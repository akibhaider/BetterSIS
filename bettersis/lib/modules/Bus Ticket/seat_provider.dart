import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeatProvider extends ChangeNotifier {
  final String userId;
  Map<String, Map<String, dynamic>> seats = {};
  bool isLoading = true;
 
  SeatProvider(this.userId) {
    _scheduleDailyReset(); // Schedule seat reset for midnight
  }

  // Fetch seats from Firestore
  Future<void> fetchSeats() async {
    isLoading = true;
    notifyListeners();
    print("Fetching seats...");

    try {
      CollectionReference seatCollection =
          FirebaseFirestore.instance.collection('seats');
      QuerySnapshot snapshot = await seatCollection.get();

      if (snapshot.docs.isEmpty) {
        print("No seats found in Firestore.");
      } else {
        print("Seats found: ${snapshot.docs.length}");
      }

      seats = {};
      for (var doc in snapshot.docs) {
        print("Seat data: ${doc.data()}");

        DateTime expirationTime = DateTime.parse(doc['expirationTime']);
        bool isExpired = DateTime.now().isAfter(expirationTime);

        seats[doc.id] = {
          'available': isExpired ? true : doc['available'],
          'selected': false,
          'occupied': !isExpired && !doc['available'],
        };

        if (isExpired) {
          await seatCollection.doc(doc.id).update({
            'available': true,
            'selectedBy': null,
            'expirationTime':
                _getEndOfDay().toIso8601String(), // Reset expiration time
          });
        }

        print(
            "Seat ${doc.id} -> Available: ${seats[doc.id]!['available']}, Occupied: ${seats[doc.id]!['occupied']}");
      }
    } catch (e) {
      print('Error fetching seats: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Toggle seat selection
  void toggleSeatSelection(String seatKey) {
    final seat = seats[seatKey];
    if (seat != null && seat['available'] == true) {
      seats[seatKey]!['selected'] = !(seats[seatKey]!['selected'] ?? false);
      notifyListeners();
    }
  }

  // Confirm seat selection and update Firestore
  Future<void> confirmSelection(String userId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var seatKey in seats.keys) {
        if (seats[seatKey]?['selected'] == true) {
          DateTime expirationTime = _getEndOfDay(); // Set expiration for today

          DocumentReference seatDoc =
              FirebaseFirestore.instance.collection('seats').doc(seatKey);
          batch.update(seatDoc, {
            'available': false,
            'selectedBy': userId,
            'expirationTime': expirationTime.toIso8601String(),
          });

          seats[seatKey]!['available'] = false;
          seats[seatKey]!['occupied'] = true;
        }
      }
      await batch.commit(); // Commit all updates at once
    } catch (e) {
      print('Error confirming seats: $e');
    }
    notifyListeners();
  }

  // Cancel seat selection
  void cancelSelection() {
    seats.forEach((seatKey, seatData) {
      seats[seatKey]!['selected'] = false;
    });
    notifyListeners();
  }

  // Schedule a task to reset seats at midnight
  void _scheduleDailyReset() {
    final now = DateTime.now();
    final midnight =
        DateTime(now.year, now.month, now.day + 1, 0, 1); // 12:01 AM
    final timeUntilMidnight = midnight.difference(now);

    Future.delayed(timeUntilMidnight, () async {
      await _resetSeats(); // Reset all seats
      _scheduleDailyReset(); // Reschedule for the next day
    });
  }

  // Reset all seats: set available and expiration time to 11:59 PM
  Future<void> _resetSeats() async {
    try {
      final seatCollection = FirebaseFirestore.instance.collection('seats');
      final batch = FirebaseFirestore.instance.batch();
      QuerySnapshot snapshot = await seatCollection.get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'available': true,
          'selectedBy': null,
          'expirationTime': _getEndOfDay().toIso8601String(), // Set to 11:59 PM
        });

        seats[doc.id] = {
          'available': true,
          'selected': false,
          'occupied': false,
        };
      }

      await batch.commit(); // Commit the batch update
      print("All seats have been reset and made available.");
    } catch (e) {
      print('Error resetting seats: $e');
    }
    notifyListeners();
  }

  // Helper method to get the end of the current day (11:59 PM)
  DateTime _getEndOfDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59);
  }
}

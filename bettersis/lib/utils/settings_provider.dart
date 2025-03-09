import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _allowNotifications = true;
  bool _isSetLimit = true;
  int _limit = 11000;

  bool get allowNotifications => _allowNotifications;
  bool get isSetLimit => _isSetLimit;
  int get limit => _limit;

  void setAllowNotifications(bool an) {
    _allowNotifications = an;
    notifyListeners();
  }

  void setIsSetLimit(bool isl) {
    _isSetLimit = isl;
    notifyListeners();
  }

  Future<void> storeLimitInFirestore(String userId) async {
    try {
      final documentRef =
          FirebaseFirestore.instance.collection('Internet').doc(userId);

      await documentRef.set({
        'limit': _limit,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error storing limit in Firestore: $e');
    }
  }

  Future<void> fetchLimitInFirestore(String userId) async {
    try {
      final documentRef =
          FirebaseFirestore.instance.collection('Internet').doc(userId);
      final documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;

        _limit = data['limit'];
      }
    } catch (e) {
      print('Couldn\'t fint user credentials. Make sure you set them.');
    }
  }

  int getLimit(String userId) {
    fetchLimitInFirestore(userId);
    return _limit;
  }

  void setLimit(int lmt, String userId) {
    _limit = lmt;
    setIsSetLimit(true);
    storeLimitInFirestore(userId);
    notifyListeners();
  }
}

import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/screens/Student/Smart%20Wallet/smart_wallet.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'busToken.dart';

class ViewBusTokens extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ViewBusTokens({
    super.key,
    required this.userData,
  });

  @override
  State<ViewBusTokens> createState() => _ViewBusTokensState();
}

class _ViewBusTokensState extends State<ViewBusTokens> {
  List<Map<String, dynamic>> tokensList = [];
  bool isLoading = true;
  String? userId;
  smartWalletPage walletP = smartWalletPage();

  @override
  void initState() {
    super.initState();

    if (widget.userData.containsKey('id')) {
      userId = widget.userData['id'];
    }

    if (userId != null) {
      _fetchTokensFromFirestore();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTokensFromFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      print("Attempting to fetch bus tokens for user ID: $userId");

      // Check if the user document exists in BusTokens collection
      final userDocRef =
          FirebaseFirestore.instance.collection('BusTokens').doc(userId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        print("No BusTokens document found for user ID: $userId");
        setState(() {
          isLoading = false;
          tokensList = [];
        });
        return;
      }

      print("User document exists in BusTokens collection");

      // Try to fetch the tokens subcollection
      final tokenCollection = userDocRef.collection('userBusTokens');
      final querySnapshot = await tokenCollection.get();

      print(
          "Found ${querySnapshot.docs.length} tokens in userBusTokens collection");

      DateTime now = DateTime.now();
      List<Map<String, dynamic>> validTokens = [];
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Debug the first token if any exist
      if (querySnapshot.docs.isNotEmpty) {
        print("First token data sample: ${querySnapshot.docs.first.data()}");
      }

      for (var doc in querySnapshot.docs) {
        try {
          String tokenDateStr = doc['date'];
          print("Processing token with date: $tokenDateStr");

          DateTime tokenDate =
              DateFormat('dd-MM-yyyy HH:mm:ss').parse(tokenDateStr);
          // Add 24 hours to get expiry time
          DateTime expiryDate = tokenDate.add(const Duration(days: 1));

          print("Token date: $tokenDate, Expiry: $expiryDate, Now: $now");
          print("Is token valid? ${expiryDate.isAfter(now)}");

          if (expiryDate.isAfter(now)) {
            // Token is still valid
            validTokens.add({
              'bus': doc['bus'],
              'date': doc['date'],
              'selectedType': doc['selectedType'],
              'seatId': doc['seatId'],
              'tokenId': doc['tokenId'],
            });
            print("Added valid token: ${doc['tokenId']}");
          } else {
            // Token is expired, mark for deletion
            batch.delete(doc.reference);
            print("Marking expired token for deletion: ${doc['tokenId']}");
          }
        } catch (e) {
          print("Error processing token document: $e");
          print("Problematic document data: ${doc.data()}");
        }
      }

      // Only commit batch if there are expired tokens to delete
      if (querySnapshot.docs.length != validTokens.length) {
        await batch.commit();
        print(
            "Deleted ${querySnapshot.docs.length - validTokens.length} expired tokens");
      }

      setState(() {
        tokensList = validTokens;
        isLoading = false;
      });

      print("Final token list count: ${tokensList.length}");
    } catch (e) {
      print('Error fetching tokens: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show refund dialog if the token is refundable
  // Show refund dialog if the token is refundable
  Future<void> _showRefundDialog(
      String tokenId, Map<String, dynamic> token) async {
    DateTime tokenDate = DateFormat('dd-MM-yyyy HH:mm:ss').parse(token['date']);
    DateTime today = DateTime.now();

    // Extract the date part only from token date (ignore the time)
    DateTime tokenDateOnly =
        DateTime(tokenDate.year, tokenDate.month, tokenDate.day);
    DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    // Set the departure time to 7:00 AM on token's date
    DateTime departureTime = DateTime(
        tokenDateOnly.year, tokenDateOnly.month, tokenDateOnly.day, 7, 0, 0);

    // Create the cutoff time (6:30 AM on the same day)
    DateTime cutoffTime = DateTime(
        tokenDateOnly.year, tokenDateOnly.month, tokenDateOnly.day, 6, 30, 0);

    bool isRefundable = false;
    String refundMessage = '';

    // Check if token is for today
    bool isToday = tokenDateOnly.isAtSameMomentAs(todayDateOnly);

    // If it's today's ticket
    if (isToday) {
      // Check current time against the restricted window
      if (today.hour == 6 && today.minute >= 30 ||
          today.hour == 7 && today.minute == 0) {
        // Current time is between 6:30 AM and 7:00 AM - NOT refundable
        isRefundable = false;
        refundMessage =
            'Tickets cannot be refunded between 6:30 AM and 7:00 AM.';
        print(
            "Current time is in restricted window (6:30-7:00 AM) - refund NOT allowed");
      } else if (departureTime.difference(today).inMinutes <= 30) {
        // Less than 30 minutes before departure - NOT refundable
        isRefundable = false;
        refundMessage =
            'Token cannot be refunded less than 30 minutes before departure.';
        print("Less than 30 minutes before departure - refund NOT allowed");
      } else {
        // Outside restricted window and more than 30 mins before departure - refundable
        isRefundable = true;
        print(
            "Outside restricted window and >30 mins before departure - refund allowed");
      }
    } else if (tokenDateOnly.isAfter(todayDateOnly)) {
      // Future ticket - always refundable
      isRefundable = true;
      print("Future ticket - refund allowed");
    } else {
      // Past ticket - not refundable
      isRefundable = false;
      refundMessage = 'Past tickets cannot be refunded.';
      print("Past ticket - refund NOT allowed");
    }

    print("Is refundable: $isRefundable");

    if (!isRefundable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(refundMessage)),
      );
      return;
    }

    // Continue with refund process if allowed
    bool confirmRefund =
        await _showConfirmationDialog('Refund this bus token?');

    if (confirmRefund) {
      await _processRefund(tokenId, token);
    }
  }

  // Confirmation dialog for refund
  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Refund'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Refund'),
            ),
          ],
        );
      },
    );
  }

  // Process refund logic for bus tokens
  // Process refund logic for bus tokens
  Future<void> _processRefund(
      String tokenId, Map<String, dynamic> token) async {
    int refundAmount = 0;

    // Determine refund amount based on trip type
    if (token['selectedType'] == 'One Way (Uttara - IUT)' ||
        token['selectedType'] == 'One Way (IUT - Uttara)') {
      refundAmount = 30;
    } else if (token['selectedType'] == 'Round Trip') {
      refundAmount = 60;
    }

    try {
      // 1. Fetch the user's current balance
      double currentBalance = await walletP.getBalance(widget.userData['id']);

      // 2. Update the balance
      double refundAmountAsDouble = refundAmount.toDouble();
      double newBalance = currentBalance + refundAmountAsDouble;
      await walletP.updateBalance(widget.userData['id'], newBalance);

      // 3. Log the refund transaction
      await walletP.addTransaction(widget.userData['id'], 'Bus Refund',
          refundAmountAsDouble, 'transportation');
      print('- Bus Token Refund Successful');

      // 4. FREE UP THE REFUNDED SEATS IN THE DATABASE - This is the new part
      await _freeUpRefundedSeats(token);

      // 5. Delete the refunded token
      DocumentReference tokenRef = FirebaseFirestore.instance
          .collection('BusTokens')
          .doc(userId)
          .collection('userBusTokens')
          .doc(tokenId);

      await tokenRef.delete();

      // 6. Update the UI
      _fetchTokensFromFirestore();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus token refunded successfully!')),
      );
    } catch (e) {
      print('Error processing bus refund: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process refund.')),
      );
    }
  }

// New method to free up seats after refund
  Future<void> _freeUpRefundedSeats(Map<String, dynamic> token) async {
    try {
      // Parse the token date to get the correct day document
      DateTime tokenDate =
          DateFormat('dd-MM-yyyy HH:mm:ss').parse(token['date']);

      // Format the date in the correct path structure: Bus/YYYY/MM/DD
      final year = tokenDate.year.toString();
      final month = tokenDate.month.toString().padLeft(2, '0');
      final day =
          tokenDate.day.toString(); // Day WITHOUT padding as per SeatProvider
      final dayDocPath = 'Bus/$year/$month/$day';

      print("DEBUG: Attempting to free up seats in document: $dayDocPath");
      print("DEBUG: Token date: ${tokenDate.toString()}");
      print("DEBUG: Formatted path: $dayDocPath");

      // Reference to the day document with the correct path
      DocumentReference dayDocRef = FirebaseFirestore.instance.doc(dayDocPath);

      // First check if document exists
      final docSnapshot = await dayDocRef.get();
      print("DEBUG: Document exists: ${docSnapshot.exists}");

      if (!docSnapshot.exists) {
        print("ERROR: Document does not exist at path: $dayDocPath");
        throw Exception("Document not found at path: $dayDocPath");
      }

      // Get the seats array from the document
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> seats = List.from(data['seats']);
      print("DEBUG: Found ${seats.length} seats in document");

      // Get the seatId value and handle various possible formats
      var rawSeatId = token['seatId'];
      print(
          "DEBUG: Raw seatId type: ${rawSeatId.runtimeType}, value: $rawSeatId");

      List<String> seatStrings = [];

      // Handle different possible formats of seatId
      if (rawSeatId is String) {
        // If it's a string (comma-separated), split it
        seatStrings = rawSeatId.split(',').map((s) => s.trim()).toList();
      } else if (rawSeatId is List) {
        // If it's already a list, convert elements to strings
        seatStrings = rawSeatId.map((item) => item.toString().trim()).toList();
      } else {
        print("ERROR: Unexpected seatId format: $rawSeatId");
        throw Exception("Invalid seat ID format");
      }

      print("DEBUG: Parsed seat strings: $seatStrings");

      // Convert to 0-based indices (seat numbers to array indices)
      List<int> seatIndices = [];
      for (String seatStr in seatStrings) {
        int? seatNumber = int.tryParse(seatStr);
        if (seatNumber != null) {
          // Convert from 1-based to 0-based if these are seat numbers
          // If they're already indices, use them directly
          int arrayIndex = seatNumber - 1;
          seatIndices.add(arrayIndex);
          print("DEBUG: Adding index $arrayIndex to free up");
        }
      }

      if (seatIndices.isEmpty) {
        print("WARNING: No valid seat indices found to free up");
        return;
      }

      print("DEBUG: Final seat indices to update: $seatIndices");

      // Update ONLY the specific seats from the token
      for (int index in seatIndices) {
        if (index >= 0 && index < seats.length) {
          print("DEBUG: Before update, seat $index has data: ${seats[index]}");

          // Update the seat data to make it available again
          seats[index] = {
            'status': true, // Available
            'selected': false, // Not selected
            'id': '', // No user ID
            'tripTypeValue': 0 // Reset trip type
          };

          print("DEBUG: After update, seat $index has data: ${seats[index]}");
        } else {
          print(
              "WARNING: Seat index $index is out of range (0-${seats.length - 1})");
        }
      }

      // Update the seats in the Firestore document
      print("DEBUG: Updating Firestore document with modified seats array");
      await dayDocRef.update({'seats': seats});
      print("SUCCESS: Updated seats in Firestore document: $dayDocPath");
    } catch (e) {
      print("ERROR in _freeUpRefundedSeats: ${e.toString()}");
      // More detailed error info
      if (e is FirebaseException) {
        print("Firebase error code: ${e.code}");
        print("Firebase error message: ${e.message}");
      }
      throw e; // Re-throw to handle in the calling method
    }
  }

  // Show transfer dialog
  Future<void> _showTransferDialog(
      String tokenId, Map<String, dynamic> token) async {
    TextEditingController recipientController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Bus Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the ID of the receiving user:'),
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter User ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String recipientUserId = recipientController.text.trim();
              Navigator.pop(context);
              await _transferToken(tokenId, token, recipientUserId);
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  // Transfer token logic
  Future<void> _transferToken(String tokenId, Map<String, dynamic> token,
      String recipientUserId) async {
    try {
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: recipientUserId)
          .get();

      if (userQuerySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found!')),
        );
        return;
      }

      var recipientUserData = userQuerySnapshot.docs.first.data();
      String recipientName = recipientUserData['name'];

      bool confirmTransfer =
          await _showTransferConfirmationDialog(recipientName);

      if (!confirmTransfer) {
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference currentUserTokenRef = FirebaseFirestore.instance
          .collection('BusTokens')
          .doc(widget.userData['id'])
          .collection('userBusTokens')
          .doc(tokenId);

      batch.delete(currentUserTokenRef);

      DocumentReference recipientUserTokenRef = FirebaseFirestore.instance
          .collection('BusTokens')
          .doc(recipientUserId)
          .collection('userBusTokens')
          .doc(tokenId);

      batch.set(recipientUserTokenRef, {
        'bus': token['bus'],
        'date': token['date'],
        'selectedType': token['selectedType'],
        'seatId': token['seatId'],
        'tokenId': token['tokenId'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _fetchTokensFromFirestore();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus token transferred successfully!')),
      );
    } catch (e) {
      print('Error transferring token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to transfer token.')),
      );
    }
  }

  // Confirmation dialog for transfer
  Future<bool> _showTransferConfirmationDialog(String recipientName) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Transfer'),
          content: Text(
              'Are you sure you want to transfer this bus token to $recipientName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double cardWidth = screenWidth * 0.45;
    double cardHeight = screenHeight * 0.25;

    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: Utils.getLogout(),
        theme: theme,
        title: 'View Bus Tokens',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tokensList.isEmpty
              ? const Center(child: Text('No bus tokens available'))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: cardWidth / cardHeight,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  itemCount: tokensList.length,
                  itemBuilder: (context, index) {
                    final token = tokensList[index];
                    // Parse the date for display
                    DateTime tokenDate =
                        DateFormat('dd-MM-yyyy HH:mm:ss').parse(token['date']);
                    String displayDate =
                        DateFormat('dd-MM-yyyy').format(tokenDate);

                    return GestureDetector(
                      // Single-tap for view QR
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusToken(
                              userId: widget.userData['id'],
                              userDept: widget.userData['dept'],
                              onLogout: Utils.getLogout(),
                              userName: widget.userData['name'],
                              bus: token['bus'],
                              date: token['date'],
                              seatId: token['seatId'],
                              selectedType: token['selectedType'],
                            ),
                          ),
                        );
                      },
                      // Double-tap for refund
                      onDoubleTap: () {
                        _showRefundDialog(token['tokenId'], token);
                      },
                      // Long press for transfer
                      onLongPress: () {
                        _showTransferDialog(token['tokenId'], token);
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.secondaryHeaderColor
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                token['selectedType'].toString().length > 15
                                    ? token['selectedType']
                                            .toString()
                                            .substring(0, 15) +
                                        '...'
                                    : token['selectedType'].toString(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                displayDate,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "Seat: ${token['seatId']}",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                token['tokenId'].substring(0, 8),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

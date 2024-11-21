import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/screens/Student/Smart%20Wallet/smart_wallet.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For parsing dates
import 'lunchtoken.dart';

class ViewTokens extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ViewTokens({
    super.key,
    required this.userData,
  });

  @override
  State<ViewTokens> createState() => _ViewTokensState();
}

class _ViewTokensState extends State<ViewTokens> {
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

  // Fetch tokens, delete expired ones, and display valid tokens
  Future<void> _fetchTokensFromFirestore() async {
    setState(() {
      isLoading = true;
    });

    final tokenCollection = FirebaseFirestore.instance
        .collection('Tokens')
        .doc(userId)
        .collection('userTokens');

    try {
      final querySnapshot = await tokenCollection.get();
      DateTime now = DateTime.now(); // Get current time

      List<Map<String, dynamic>> validTokens = [];
      WriteBatch batch = FirebaseFirestore.instance
          .batch(); // Batch for deleting expired tokens

      for (var doc in querySnapshot.docs) {
        String tokenDateStr =
            doc['date']; // Date stored in "dd-MM-yyyy HH:mm:ss"
        DateTime tokenDate =
            DateFormat('dd-MM-yyyy HH:mm:ss').parse(tokenDateStr);

        if (tokenDate.isAfter(now)) {
          // Token is still valid, add to validTokens list
          validTokens.add({
            'meal': doc['meal'],
            'date': doc['date'],
            'cafeteria': doc['cafeteria'],
            'tokenId': doc['tokenId'],
          });
        } else {
          // Token is expired, mark for deletion
          batch.delete(doc.reference);
        }
      }

      await batch.commit(); // Delete expired tokens from Firestore

      setState(() {
        tokensList = validTokens;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching tokens: $e');
    }
  }

  // Show refund dialog if the token is refundable
  Future<void> _showRefundDialog(
      String tokenId, Map<String, dynamic> token) async {
    DateTime tokenDate = DateFormat('dd-MM-yyyy HH:mm:ss').parse(token['date']);
    DateTime today = DateTime.now();

    // Check if the token date is not today for refund eligibility
    bool isRefundable = !isSameDay(tokenDate, today);

    if (!isRefundable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token cannot be refunded today.')),
      );
      return;
    }

    // Confirm the refund
    bool confirmRefund = await _showConfirmationDialog('Refund this token?');

    if (confirmRefund) {
      await _processRefund(tokenId, token);
    }
  }

  // Check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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

  // Process refund logic
  Future<void> _processRefund(
      String tokenId, Map<String, dynamic> token) async {
    int refundAmount = token['meal'] == 'Breakfast' ? 40 : 70;
    DateTime timestamp = DateTime.now();
    String formattedTimestamp = DateFormat.yMMMMd().add_jms().format(timestamp);
    

    try {
      // 1. Fetch the user's current balance
      double currentBalance = await walletP.getBalance(widget.userData['id']);
      
      // DocumentReference financeRef =
      //     FirebaseFirestore.instance.collection('Finance').doc(userId);
      // DocumentSnapshot financeSnapshot = await financeRef.get();

      // // Ensure that balance is treated as double
      // double currentBalance = (financeSnapshot['Balance'] is int)
      //     ? (financeSnapshot['Balance'] as int).toDouble()
      //     : financeSnapshot['Balance'];


      // 2. Update the balance
      double refundAmountasDouble = refundAmount.toDouble();
      double newBalance = currentBalance + refundAmountasDouble;
      await walletP.updateBalance(widget.userData['id'], newBalance);

      // double newBalance = currentBalance + refundAmount;
      // await financeRef.update({'Balance': newBalance});

      // 3. Log the refund transaction
      await walletP.addTransaction(widget.userData['id'], 'Refund', refundAmountasDouble, 'meal');
      print('- Refund Successful');
      // DocumentReference transactionRef =
      //     financeRef.collection('Transactions').doc();
      // await transactionRef.set({
      //   'amount': refundAmount,
      //   'timestamp': formattedTimestamp,
      //   'title': 'Refund',
      //   'type': 'meal',
      // });

      // 4. Delete the refunded token
      DocumentReference tokenRef = FirebaseFirestore.instance
          .collection('Tokens')
          .doc(userId)
          .collection('userTokens')
          .doc(tokenId);

      await tokenRef.delete();

      // 5. Update the UI
      _fetchTokensFromFirestore();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token refunded successfully!')),
      );
    } catch (e) {
      print('Error processing refund: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process refund.')),
      );
    }
  }

  // Show transfer dialog
  Future<void> _showTransferDialog(
      String tokenId, Map<String, dynamic> token) async {
    TextEditingController recipientController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Token'),
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
          .collection('Tokens')
          .doc(widget.userData['id'])
          .collection('userTokens')
          .doc(tokenId);

      batch.delete(currentUserTokenRef);

      DocumentReference recipientUserTokenRef = FirebaseFirestore.instance
          .collection('Tokens')
          .doc(recipientUserId)
          .collection('userTokens')
          .doc(tokenId);

      batch.set(recipientUserTokenRef, {
        'meal': token['meal'],
        'date': token['date'],
        'cafeteria': token['cafeteria'],
        'tokenId': token['tokenId'],
      });

      await batch.commit();

      _fetchTokensFromFirestore();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token transferred successfully!')),
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
              'Are you sure you want to transfer this token to $recipientName?'),
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
        title: 'View Tokens',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tokensList.isEmpty
              ? const Center(child: Text('No tokens available'))
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

                    return GestureDetector(
                      // Single-tap for view QR
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LunchToken(
                              userId: widget.userData['id'],
                              userDept: widget.userData['dept'],
                              onLogout: Utils.getLogout(),
                              userName: widget.userData['name'],
                              cafeteria: token['cafeteria'],
                              date: token['date'],
                              meal: token['meal'],
                              tokenId: token['tokenId'],
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
                                token['meal'].toUpperCase(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                token['date'],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.015),
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

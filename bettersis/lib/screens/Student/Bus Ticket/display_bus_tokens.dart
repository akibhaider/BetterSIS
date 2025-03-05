import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'busToken.dart';
import 'package:intl/intl.dart';

class DisplayBusTokens extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;
  final String bus;
  final String date;
  final String selectedType;
  final String seatId; // This can be a comma-separated list of seat IDs

  const DisplayBusTokens({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userName,
    required this.onLogout,
    required this.bus,
    required this.date,
    required this.selectedType,
    required this.seatId,
  });

  @override
  State<DisplayBusTokens> createState() => _DisplayBusTokensState();
}

class _DisplayBusTokensState extends State<DisplayBusTokens> {
  var uuid = const Uuid();
  List<Map<String, dynamic>> tokensList = [];
  bool isLoading = true;
  String tokenId = '';

  @override
  void initState() {
    super.initState();
    tokenId = uuid.v4();
    print(
        "Creating new bus token with ID: $tokenId for type: ${widget.selectedType}");

    _saveTokenToFirestore().then((_) {
      // Instead of fetching all tokens, just display the current token
      _displayCurrentToken();
    });
  }

  // New method to display only the current token
  void _displayCurrentToken() {
    setState(() {
      // Create a token object for the current purchase only
      tokensList = [
        {
          'bus': widget.bus,
          'date': widget.date,
          'selectedType': widget.selectedType,
          'seatId': widget.seatId,
          'tokenId': tokenId,
        }
      ];
      isLoading = false;
    });
    print(
        "Displaying current token for trip type: ${widget.selectedType} with seat(s): ${widget.seatId}");
  }

  Future<void> _saveTokenToFirestore() async {
    try {
      print("Saving bus token to Firestore for user: ${widget.userId}");

      // First check if the BusTokens collection exists, if not it will be created
      final busTokensCollection =
          FirebaseFirestore.instance.collection('BusTokens');

      // Check if user document exists
      final userDoc = await busTokensCollection.doc(widget.userId).get();
      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await busTokensCollection.doc(widget.userId).set({
          'created': FieldValue.serverTimestamp(),
          'userId': widget.userId,
          'tokenCount': 0
        });
        print("Created new user document in BusTokens collection");
      }

      // Reference to the user's bus tokens subcollection
      final userTokensRef =
          busTokensCollection.doc(widget.userId).collection('userBusTokens');

      // Handle the seat IDs based on the selected trip type
      final List<String> seatIds =
          widget.seatId.split(',').map((s) => s.trim()).toList();

      print(
          "Processing ${seatIds.length} seats for trip type: ${widget.selectedType}");

      // Save the token data - one token per trip type
      await userTokensRef.doc(tokenId).set({
        'bus': widget.bus,
        'date': widget.date,
        'selectedType': widget.selectedType,
        'seatId':
            widget.seatId, // Store all seat IDs for this trip type together
        'tokenId': tokenId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update token count
      await busTokensCollection.doc(widget.userId).update({
        'tokenCount': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp()
      });

      print("Successfully saved bus token to Firestore");
    } catch (e) {
      print("Error saving bus token to Firestore: $e");
    }
  }

  // Keep this method for reference, but we're not using it anymore
  Future<void> _fetchTokensFromFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      print("Fetching bus tokens from Firestore for user: ${widget.userId}");
      final tokenCollection = FirebaseFirestore.instance
          .collection('BusTokens')
          .doc(widget.userId)
          .collection('userBusTokens');

      final querySnapshot = await tokenCollection.get();
      print("Found ${querySnapshot.docs.length} tokens");

      DateTime now = DateTime.now();
      List<Map<String, dynamic>> validTokens = [];

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        try {
          String tokenDateStr = doc['date'];
          DateTime tokenDate =
              DateFormat('dd-MM-yyyy HH:mm:ss').parse(tokenDateStr);
          // Add 24 hours to the token date to get the expiry
          DateTime expiryDate = tokenDate.add(const Duration(days: 1));

          if (expiryDate.isAfter(now)) {
            // Token is still valid
            validTokens.add({
              'bus': doc['bus'],
              'date': doc['date'],
              'selectedType': doc['selectedType'],
              'seatId': doc['seatId'],
              'tokenId': doc['tokenId'],
            });
          } else {
            // Token is expired, mark it for deletion
            batch.delete(doc.reference);
          }
        } catch (e) {
          print("Error processing token: ${e}");
        }
      }

      // Commit the batch to delete expired tokens
      if (querySnapshot.docs.isNotEmpty) {
        await batch.commit();
      }

      setState(() {
        tokensList = validTokens;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bus tokens: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double cardWidth = screenWidth * 0.45;
    double cardHeight = screenHeight * 0.25;

    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Bus Tokens',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                String displayDate = DateFormat('dd-MM-yyyy').format(tokenDate);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusToken(
                          userId: widget.userId,
                          userDept: widget.userDept,
                          onLogout: widget.onLogout,
                          userName: widget.userName,
                          bus: token['bus'],
                          date: token['date'],
                          seatId: token['seatId'],
                          selectedType: token['selectedType'],
                        ),
                      ),
                    );
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
                            "Seats: ${token['seatId']}",
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

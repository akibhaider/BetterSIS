import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'lunchtoken.dart';

class DisplayTokens extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;
  final String cafeteria;
  final String? date;
  final String meal;
  final String? tokens;

  const DisplayTokens({
    Key? key,
    required this.userId,
    required this.userDept,
    required this.userName,
    required this.onLogout,
    required this.cafeteria,
    required this.date,
    required this.meal,
    required this.tokens,
  }) : super(key: key);

  @override
  State<DisplayTokens> createState() => _DisplayTokensState();
}

class _DisplayTokensState extends State<DisplayTokens> {
  late int tokenCount;
  var uuid = Uuid();
  List<Map<String, dynamic>> tokensList = [];
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    tokenCount = int.tryParse(widget.tokens ?? '0') ?? 0;

    _saveTokensToFirestore().then((_) {
      _fetchTokensFromFirestore();
    });
  }

  Future<void> _saveTokensToFirestore() async {
    final batch = FirebaseFirestore.instance.batch();
    final userTokensRef = FirebaseFirestore.instance
        .collection('Tokens')
        .doc(widget.userId)
        .collection('userTokens');

    for (int i = 0; i < tokenCount; i++) {
      String tokenId = uuid.v4();
      batch.set(userTokensRef.doc(tokenId), {
        'meal': widget.meal,
        'date': widget.date,
        'cafeteria': widget.cafeteria,
        'tokenId': tokenId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> _fetchTokensFromFirestore() async {
    setState(() {
      isLoading = true; 
    });

    final tokenCollection = FirebaseFirestore.instance
        .collection('Tokens')
        .doc(widget.userId)
        .collection('userTokens');

    final querySnapshot = await tokenCollection.get();
    setState(() {
      tokensList = querySnapshot.docs
          .map((doc) => {
                'meal': doc['meal'],
                'date': doc['date'],
                'cafeteria': doc['cafeteria'],
                'tokenId': doc['tokenId'],
              })
          .toList();
      isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double cardWidth = screenWidth * 0.45;
    double cardHeight = screenHeight * 0.25;

    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme ),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Tokens',
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

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LunchToken(
                          userId: widget.userId,
                          userDept: widget.userDept,
                          onLogout: widget.onLogout,
                          userName: widget.userName,
                          cafeteria: token['cafeteria'],
                          date: token['date'],
                          meal: token['meal'],
                          tokenId: token['tokenId'],
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

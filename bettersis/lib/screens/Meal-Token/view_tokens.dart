import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'lunchtoken.dart';

class ViewTokens extends StatefulWidget {
  final Map<String, dynamic> userData; // The user data map is passed

  const ViewTokens({
    Key? key,
    required this.userData, // Required userData parameter
  }) : super(key: key);

  @override
  State<ViewTokens> createState() => _ViewTokensState();
}

class _ViewTokensState extends State<ViewTokens> {
  List<Map<String, dynamic>> tokensList = [];
  bool isLoading = true; // Loading indicator for async actions
  String? userId;

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

    final tokenCollection = FirebaseFirestore.instance
        .collection('Tokens')
        .doc(userId)
        .collection('userTokens');

    try {
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
    } catch (e) {
      setState(() {
        isLoading = false; 
      });
      print('Error fetching tokens: $e');
    }
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
              ? const Center(
                  child: Text('No tokens available')) 
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

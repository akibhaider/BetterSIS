import 'package:bettersis/screens/Misc/settings_page.dart';
import 'package:bettersis/screens/Student/Bus%20Ticket/view_bus_tokens.dart';
import 'package:bettersis/screens/Student/Notice/notice_board.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import '../Student/Meal-Token/view_tokens.dart';

class CustomAppDrawer extends StatefulWidget {
  final ThemeData theme;

  const CustomAppDrawer({super.key, required this.theme});

  @override
  _CustomAppDrawerState createState() => _CustomAppDrawerState();
}

class _CustomAppDrawerState extends State<CustomAppDrawer>
    with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Map<String, dynamic> userData;

  String balance = "Fetching...";

  @override
  void initState() {
    super.initState();
    userData = Utils.getUser();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-1.5, 0),
    ).animate(_controller);

    _fetchUserBalance();
  }

  // Function to fetch the balance from Firestore
  Future<void> _fetchUserBalance() async {
    try {
      String userId = userData['id'];

      DocumentSnapshot financeDoc = await FirebaseFirestore.instance
          .collection('Finance')
          .doc(userId)
          .get();

      if (financeDoc.exists && financeDoc.data() != null) {
        setState(() {
          balance = '৳${financeDoc['Balance']}';
        });
      } else {
        setState(() {
          balance = "No data";
        });
      }
    } catch (e) {
      setState(() {
        balance = "Error";
      });
    }
  }

  void _toggleBalance() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
      if (_isBalanceVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double paddingValue = screenWidth * 0.04;
    final double fontSize = screenWidth * 0.04;
    final double borderWidth = screenWidth * 0.003;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.theme.secondaryHeaderColor,
                  widget.theme.primaryColor
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize * 1.2,
                  ),
                ),
                SizedBox(height: paddingValue),
                GestureDetector(
                  onTap: _toggleBalance,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: paddingValue * 0.75,
                        horizontal: paddingValue),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15.0),
                      border:
                          Border.all(color: Colors.white, width: borderWidth),
                    ),
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.35,
                    child: Stack(
                      children: [
                        SlideTransition(
                          position: _slideAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.currency_pound_sharp,
                                  color: Colors.white, size: fontSize),
                              SizedBox(width: 5),
                              Text(
                                "Balance",
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: AnimatedOpacity(
                            opacity: _isBalanceVisible ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              balance, // Display the fetched balance
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text(
              'Notice Board',
              style: TextStyle(fontSize: fontSize),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoticeBoard(),
                  ));
            },
          ),
          ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(
                'My Lunch Tokens',
                style: TextStyle(fontSize: fontSize),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewTokens(userData: userData),
                    ));
              }),
          ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(
                'My Bus Tokens',
                style: TextStyle(fontSize: fontSize),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewBusTokens(userData: userData),
                    ));
              }),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(
              'Settings',
              style: TextStyle(fontSize: fontSize),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      userId: userData['id'],
                      userDept: userData['dept'],
                      onLogout: Utils.getLogout(),
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }
}

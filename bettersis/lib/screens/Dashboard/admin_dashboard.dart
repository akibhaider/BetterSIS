import 'package:bettersis/screens/Complain/complain_page.dart';
import 'package:bettersis/screens/Teacher/Attendance/attendance.dart';
import 'package:bettersis/screens/Teacher/Classes/classes.dart';
import 'package:bettersis/screens/Admin/accountCreator.dart';
import 'package:bettersis/screens/Admin/Course/addCourse.dart';
import 'package:bettersis/screens/Admin/Course/mainCoursePage.dart';
import 'package:bettersis/screens/Admin/Course/deleteCourse.dart';
import 'package:bettersis/screens/Admin/Course/editCourse.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../utils/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Misc/login_page.dart';
import '../../modules/bettersis_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminDashboard({super.key, required this.userData});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchImageUrl();
    Utils.setLogout(_logout);
  }

  Future<void> fetchImageUrl() async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child('admin.jpg');
      String url = await storageRef.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Error fetching image URL: $e');
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToAdminTest() {
    // Add Submit Result page navigation here
  }

  void _navigateToAccountCreation() {
    // Add Submit Result page navigation here
  }

  void _navigateToCourse() {
    // Add Submit Result page navigation here
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required ThemeData themeData,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: themeData.primaryColor,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize, // Dynamic font size
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme('admin');
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: BetterSISAppBar(
          onLogout: _logout,
          theme: theme,
          title: 'Dashboard',
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: theme.primaryColor,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4.0,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(imageUrl),
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading image: $exception');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14 * scaleFactor,
                            ),
                          ),
                          Text(
                            widget.userData['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3.5),
                          Text(
                            "Admin of BetterSIS",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'SERVICES',
                  style: TextStyle(
                    fontSize: 20 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = screenWidth > 600 ? 4 : 3;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 30,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildServiceButton(
                        icon: Icons.assignment,
                        label: "Admin Test Button",
                        themeData: theme,
                        onTap: _navigateToAdminTest,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.account_circle_rounded,
                        label: "Create Account",
                        themeData: theme,
                        onTap: _navigateToAccountCreation,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.school_rounded,
                        label: "Course",
                        themeData: theme,
                        onTap: _navigateToCourse,
                        fontSize: 14 * scaleFactor,
                      ),
                
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '2024 @ HafeziCodingBlackEdition',
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

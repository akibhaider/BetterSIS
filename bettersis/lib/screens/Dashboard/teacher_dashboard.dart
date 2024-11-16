import 'package:bettersis/screens/Complain/complain_page.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../utils/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Misc/login_page.dart';
import '../../modules/bettersis_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TeacherDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TeacherDashboard({super.key, required this.userData});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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
      String email = widget.userData['email'];
      String fileName = '$email.png'; 
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
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

  void _navigateToSubmitResult() {
    // Add Submit Result page navigation here
  }

  void _navigateToAttendance() {
    // Add Attendance page navigation here
  }

  void _navigateToAnnouncement() {
    // Add Announcement page navigation here
  }

  void _navigateToClasses() {
    // Add Classes page navigation here
  }

  void _navigateToAcademics() {
    // Add Academics page navigation here
  }

  void _navigateToComplain() {
    // Add Complaim Page navigation here
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
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);
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
                            "${widget.userData['designation']}, ${widget.userData['dept'].toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          Text(
                            "${widget.userData['specialization']}",
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
                        label: "Submit Result",
                        themeData: theme,
                        onTap: _navigateToSubmitResult,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.check,
                        label: "Attendance",
                        themeData: theme,
                        onTap: _navigateToAttendance,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.announcement,
                        label: "Announcement",
                        themeData: theme,
                        onTap: _navigateToAnnouncement,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.class_,
                        label: "Classes",
                        themeData: theme,
                        onTap: _navigateToClasses,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.book,
                        label: "Academics",
                        themeData: theme,
                        onTap: _navigateToAcademics,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.report_problem,
                        label: "Complain",
                        themeData: theme,
                        onTap: _navigateToComplain,
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

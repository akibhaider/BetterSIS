import 'package:flutter/material.dart';
import '../utis/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'lunchtoken.dart';
import '../modules/bettersis_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'result_page.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Dashboard({super.key, required this.userData});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchImageUrl();
  }

  Future<void> fetchImageUrl() async {
    try {
      String userId = widget.userData['id'];
      String fileName = '$userId.png';
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

  void _navigateToLunchToken() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LunchToken(
            userId: widget.userData['id'],
            userDept: widget.userData['dept'],
            userName: widget.userData['name'],
            onLogout: _logout),
      ),
    );
  }

  void _navigateToResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultPage(onLogout: _logout, userData: widget.userData),
      ),
    );
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
    double scaleFactor = screenWidth / 375; // Base width for scaling font size

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
                              fontSize: 14 * scaleFactor, // Scaled font size
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
                          const SizedBox(height: 4),
                          Text(
                            "ID: ${widget.userData['id']}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Department: ${widget.userData['dept'].toString().toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Program: ${widget.userData['program'].toString().toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Current Semester: ${widget.userData['semester']}",
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
                        label: "Result",
                        themeData: theme,
                        onTap: _navigateToResult,
                        fontSize: 14 * scaleFactor, // Scaled font size
                      ),
                      _buildServiceButton(
                        icon: Icons.account_balance_wallet,
                        label: "Smart Wallet",
                        themeData: theme,
                        onTap: () {},
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.book,
                        label: "Academics",
                        themeData: theme,
                        onTap: () {},
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.restaurant_menu,
                        label: "Meal Token",
                        themeData: theme,
                        onTap: _navigateToLunchToken,
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.local_library,
                        label: "Library",
                        themeData: theme,
                        onTap: () {},
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.directions_bus,
                        label: "Transportation",
                        themeData: theme,
                        onTap: () {},
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.wifi,
                        label: "Internet",
                        themeData: theme,
                        onTap: () {},
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.attach_money,
                        label: "Allowance",
                        themeData: theme,
                        onTap: () {},
                        fontSize: 14 * scaleFactor,
                      ),
                      _buildServiceButton(
                        icon: Icons.report_problem,
                        label: "Complain",
                        themeData: theme,
                        onTap: () {},
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

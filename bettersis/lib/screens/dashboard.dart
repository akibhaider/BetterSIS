import 'package:flutter/material.dart';
import '../utis/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'lunchtoken.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Dashboard({super.key, required this.userData});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle logout
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToLunchToken() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LunchToken(userId: widget.userData['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: theme.primaryColor,
          automaticallyImplyLeading: false, // To remove the back button
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0), // Add padding here
            child: Column(
              children: [
                // 'BetterSIS' Title with rounded borders
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white),
                  ),
                  child: const Text(
                    'BetterSIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 'Dashboard' title
                const Text(
                  'DASHBOARD',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true, // Center the title in the AppBar
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: theme.primaryColor,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black, 
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome!',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          widget.userData['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, 
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ID: ${widget.userData['id']}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Department: ${widget.userData['dept'].toString().toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Current Semester: ${widget.userData['semester']}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Generate QR button
            ElevatedButton.icon(
              onPressed: _navigateToLunchToken,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate Lunch Token', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

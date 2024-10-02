import 'package:flutter/material.dart';
import '../utis/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'lunchtoken.dart';
import '../modules/dashboard_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child(fileName);
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
        appBar: DashboardAppBar(
          onLogout: _logout,
          theme: theme,
        ),
        body: Column(
          children: [
            Container(
              color: theme.primaryColor,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 110.0, 
                    height: 110.0,
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
                          "Program: ${widget.userData['program'].toString().toUpperCase()}",
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

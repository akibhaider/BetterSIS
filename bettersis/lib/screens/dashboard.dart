import 'package:flutter/material.dart';
import '../utis/themes.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: theme.primaryColor,
          shadowColor: theme.secondaryHeaderColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${widget.userData['name']}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Email: ${widget.userData['email']}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Dept: ${widget.userData['dept']}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("ID: ${widget.userData['id']}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Phone: ${widget.userData['phone']}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Section: ${widget.userData['section']}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Type: ${widget.userData['type']}", style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bettersis/screens/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login function using Firebase Auth
  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both email and password.");
      return;
    }

    // Email domain check for 'iut-dhaka.edu'
    if (!email.endsWith('@iut-dhaka.edu')) {
      _showErrorDialog("Only emails with the domain '@iut-dhaka.edu' are allowed.");
      return;
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${userCredential.user?.email}');
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => const Dashboard()
        )
      );
    } catch (e) {
      _showErrorDialog("Login failed. Please check your credentials.");
      print('Login error: $e');
    }
  }

  // Function to display error messages
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Function to contact ICT Center via email
  Future<void> _contactICTCenter() async {
    const url = 'mailto:ict@iut-dhaka.edu';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 20.0),
              ),
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 20.0),
              ),
              style: const TextStyle(fontSize: 18.0),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 22.0),
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _contactICTCenter,
              child: const Text(
                'Contact ICT Center',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

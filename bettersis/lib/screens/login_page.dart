import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Dummy login function
  void _loginDummy() {
    print('Login button pressed');
  }

  // Function to contact ICT Center via email
  Future<void> _contactICTCenter() async {
    const url = 'mailto:ict@iut-dhaka.edu'; // Replace with actual contact email
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(fontSize: 20.0), // Larger font for the label
            ),
            style: const TextStyle(fontSize: 18.0), // Larger font for input text
          ),
          const SizedBox(height: 20),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(fontSize: 20.0), // Larger font for the label
            ),
            style: const TextStyle(fontSize: 18.0), // Larger font for input text
            obscureText: true,
          ),
          const SizedBox(height: 40), // More space before the button
          ElevatedButton(
            onPressed: _loginDummy,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 22.0), // Larger font for the button
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0), // Larger button
              backgroundColor: Colors.blue, // Button background color
              foregroundColor: Colors.white, // Button text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
            ),
            child: const Text('Login'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _contactICTCenter,
            child: const Text(
              'Contact ICT Center',
              style: TextStyle(fontSize: 18.0), // Larger font for the contact button
            ),
          ),
        ],
      ),
    );
  }
}

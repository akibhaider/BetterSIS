import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard.dart'; 
import '../modules/custom_appbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Function to log in user and fetch Firestore data
  Future<void> _loginAndFetchData() async {
    setState(() {
      isLoading = true; 
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String email = currentUser.email!;

        // Fetch user data from Firestore
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var userData = snapshot.docs.first.data() as Map<String, dynamic>;
          print('User Data: $userData');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(userData: userData),
            ),
          );
        } else {
          print('User not found in Firestore');
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Login error: $e');
    }

    setState(() {
      isLoading = false; 
    });
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
    double appBarHeight = MediaQuery.of(context).size.height * 0.40;

    return Scaffold(
      appBar: CustomAppBar(
              appbarHeight: appBarHeight),
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
              onPressed: isLoading ? null : _loginAndFetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, 
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0), 
                textStyle: const TextStyle(fontSize: 22.0),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _contactICTCenter,
              child: const Text(
                'Contact ICT Centre',
                style: TextStyle(fontSize: 18.0), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

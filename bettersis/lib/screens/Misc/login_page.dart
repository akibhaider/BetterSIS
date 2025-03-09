import 'package:bettersis/screens/Dashboard/admin_dashboard.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:platform/platform.dart';
import '../Dashboard/dashboard.dart';
import '../Dashboard/teacher_dashboard.dart';
import '../../modules/custom_appbar.dart';
import '../../modules/show_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController _senderEmailController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // Function to log in user and fetch Firestore data
  Future<void> _loginAndFetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Log in the user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
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
          Utils.setUser(userData);
          print('User Data: $userData');

          // Safety checks for user data
          final userType = userData['type'] ?? '';
          if (userType == 'student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(userData: userData),
              ),
            );
          } else if (userType == 'teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherDashboard(userData: userData),
              ),
            );
          } else if (userType == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDashboard(userData: userData),
              ),
            );
          } else {
            setState(() {
              errorMessage = 'Unknown user type.';
            });
          }
        } else {
          setState(() {
            errorMessage = 'User not found in Firestore.';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Login error: ${e.message}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to contact ICT Center via email
  Future<void> _contactICTCenter() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact ICT Center'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your Gmail address:'),
            const SizedBox(height: 16),
            TextField(
              controller: _senderEmailController,
              decoration: const InputDecoration(
                hintText: 'your.email@gmail.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _senderEmailController.text.trim();
              if (email.isEmpty || !email.endsWith('@gmail.com')) {
                ShowMessage.error(context, 'Please enter a valid Gmail address');
                return;
              }

              Navigator.pop(context);

              try {
                if (LocalPlatform().isAndroid) {
                  final intent = AndroidIntent(
                    action: 'android.intent.action.SEND',
                    type: 'message/rfc822',
                    arguments: {
                      'android.intent.extra.EMAIL': ['ict@iut-dhaka.edu'],
                      'android.intent.extra.SUBJECT': 'BetterSIS Support Request',
                      'android.intent.extra.TEXT': '',  // Empty body
                    },
                    package: 'com.google.android.gm',  // Gmail package
                  );
                  await intent.launch();
                } else {
                  // For iOS and other platforms
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'ict@iut-dhaka.edu',
                    queryParameters: {
                      'subject': 'BetterSIS Support Request',
                      'body': '',  // Empty body
                    },
                  );

                  if (await canLaunchUrlString(emailLaunchUri.toString())) {
                    await launchUrlString(
                      emailLaunchUri.toString(),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    ShowMessage.error(context, 'Could not launch email client');
                  }
                }
              } catch (e) {
                ShowMessage.error(context, 'Failed to open email client');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = MediaQuery.of(context).size.height * 0.40;

    return Scaffold(
      appBar: CustomAppBar(appbarHeight: appBarHeight),
      body: SingleChildScrollView(
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 50.0, vertical: 15.0),
                textStyle: const TextStyle(fontSize: 22.0),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
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

  @override
  void dispose() {
    _senderEmailController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

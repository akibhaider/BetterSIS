import 'package:bettersis/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'modules/custom_appbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//  Future<FirebaseApp> _initializeFirebase() async {
//    FirebaseApp firebaseApp = await Firebase.initializeApp();
//    return firebaseApp;
//  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = MediaQuery.of(context).size.height * 0.40;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: CustomAppBar(
              appbarHeight: appBarHeight), // Use the CustomAppBar here
          body: const LoginPage()),
    );
  }
}

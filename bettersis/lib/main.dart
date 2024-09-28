import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'modules/custom_appbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if(kIsWeb){
  //   await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         apiKey: "AIzaSyAYc6GAxlNz-Xl2VA5N-zVkmiIhctk8UF0",
  //         authDomain: "bettersis-c967e.firebaseapp.com",
  //         projectId: "bettersis-c967e",
  //         storageBucket: "bettersis-c967e.appspot.com",
  //         messagingSenderId: "310451748620",
  //         appId: "1:310451748620:web:6ea920cb084eb1b5775329",
  //         measurementId: "G-HS1WLF6PPB"));
  // }else{
  //   await Firebase.initializeApp();
  // }
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

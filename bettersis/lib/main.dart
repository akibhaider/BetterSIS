import 'package:bettersis/firebase_options.dart';
import 'package:bettersis/modules/Bus%20Ticket/seat_provider.dart';
import 'package:bettersis/modules/Bus%20Ticket/trip_provider.dart';
import 'package:bettersis/utils/load_data.dart';
import 'package:bettersis/utils/settings_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/Misc/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    // Ensure that the provider is initialized at the root of the widget tree
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterSIS',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: LoginPage()),
    );
  }
}

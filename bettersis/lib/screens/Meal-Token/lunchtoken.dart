import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import '../../modules/qr_code_widget.dart';
import 'package:intl/intl.dart';
import '../../modules/bettersis_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class LunchToken extends StatelessWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;
  final String cafeteria;
  final String? date; 
  final String meal;
  final String tokenId;

  const LunchToken({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
    required this.userName,
    required this.cafeteria,
    required this.date,
    required this.meal,
    required this.tokenId,
  });

  Future<void> _contactCafeteria() async {
    const phoneNumber = 'tel:+8801713608968';
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double scaleFactor = screenWidth / 375;

    DateTime? currentTimestamp;

    if (date != null) {
      try {
        currentTimestamp = DateFormat('dd-MM-yyyy HH:mm:ss').parse(date!);
      } catch (e) {
        // Handle parsing error
        currentTimestamp = DateTime.now();
      }
    } else {
      currentTimestamp = DateTime.now(); 
    }

    final expiryDate = currentTimestamp.add(const Duration(days: 1));

    ThemeData theme = AppTheme.getTheme(userDept);

    String qrData =
        '$tokenId\n$userId\n${meal.toUpperCase()}\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(currentTimestamp)}\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(expiryDate)}';

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: onLogout,
        theme: theme,
        title: 'Meal Token',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${meal.toUpperCase()} TOKEN',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15 * scaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${cafeteria.toUpperCase()}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30 * scaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd-MM-yyyy').format(currentTimestamp).toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20 * scaleFactor,
              ),
            ),
            SizedBox(height: 30 * scaleFactor),
            Text(
              'Scan this QR Code',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20 * scaleFactor,
              ),
            ),
            SizedBox(
              height: screenWidth * 0.5,
              width: screenWidth * 0.5,
              child: QrCodeWidget(qrData: qrData),
            ),
            Text(
              userName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 23 * scaleFactor,
              ),
            ),
            Text(
              userId,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20 * scaleFactor,
              ),
            ),
            SizedBox(height: 15 * scaleFactor),
            Text(
              '*Meal tokens will be available for 24 hours before the meal time',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12 * scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20 * scaleFactor),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.15,
                  vertical: screenHeight * 0.02,
                ),
              ),
              child: Text(
                'Return to Tokens',
                style: TextStyle(fontSize: 16 * scaleFactor),
              ),
            ),
            TextButton(
              onPressed: _contactCafeteria,
              child: Text(
                'Contact Cafeteria Management',
                style: TextStyle(
                  fontSize: 13 * scaleFactor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
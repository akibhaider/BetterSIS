import 'package:bettersis/screens/appdrawer.dart';
import 'package:bettersis/utis/themes.dart';
import 'package:flutter/material.dart';
import '../modules/qr_code_widget.dart';
import 'package:intl/intl.dart';
import '../modules/bettersis_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class LunchToken extends StatelessWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;

  const LunchToken({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
    required this.userName,
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
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scale factor for font size
    double scaleFactor = screenWidth / 375;

    // Generate current timestamp and expiry date
    final currentTimestamp = DateTime.now();
    final expiryDate = currentTimestamp.add(const Duration(days: 1));

    ThemeData theme = AppTheme.getTheme(userDept);

    // Format the data to be stored in the QR code
    String qrData =
        '$userId\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(currentTimestamp)}\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(expiryDate)}';

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
              'LUNCH TOKEN',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30 * scaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'NORTH CAFETERIA',
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
            // Make the QR code dynamically sized based on screen width
            SizedBox(
              height: screenWidth * 0.5, // QR Code size is 50% of screen width
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
                ), // Dynamic padding
              ),
              child: Text(
                'Return to Dashboard',
                style: TextStyle(fontSize: 16 * scaleFactor),
              ),
            ),
            //SizedBox(height: 20 * scaleFactor),
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

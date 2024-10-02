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

  const LunchToken({super.key, required this.userId, required this.userDept, required this.onLogout, required this.userName});

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
    // Generate current timestamp and expiry date
    final currentTimestamp = DateTime.now();
    final expiryDate = currentTimestamp.add(const Duration(days: 1));

    ThemeData theme = AppTheme.getTheme(userDept);
    
    // Format the data to be stored in the QR code
    String qrData = '$userId\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(currentTimestamp)}\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(expiryDate)}';

    return Scaffold(
      appBar: BetterSISAppBar(
          onLogout: onLogout,
          theme: theme,
          title: 'Meal Token'
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('LUNCH TOKEN', style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              ),
            ),
            const Text('NORTH CAFETERIA', style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              ),
            ),
            Text(DateFormat('dd-MM-yyyy').format(currentTimestamp).toString(), style: const TextStyle(
              color: Colors.black,
              fontSize: 20
              ),
            ),
            const SizedBox(height: 30),
            const Text('Scan this QR Code', style: TextStyle(
              color: Colors.black,
              fontSize: 20
              ),
            ),
            QrCodeWidget(qrData: qrData), 
            Text(userName, style: const TextStyle(
              color: Colors.black,
              fontSize: 23
              ),
            ),
            Text(userId, style: const TextStyle(
              color: Colors.black,
              fontSize: 20
              ),
            ),
            const SizedBox(height: 15),
            const Text('*Meal tokens will be available for 24 hours before the meal time', style: TextStyle(
              color: Colors.black,
              fontSize: 12
              ),
            ),
            const SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white, 
              ),
              child: const Text('Return to Dashboard'),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: _contactCafeteria,
              child: const Text(
                'Contact Cafeteria Management',
                style: TextStyle(fontSize: 15), 
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import '../../../modules/qr_code_widget.dart';
import 'package:intl/intl.dart';
import '../../../modules/bettersis_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class BusToken extends StatelessWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;
  final String bus;
  final String? date;
  //final String meal;
  final String seatId;

  const BusToken({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
    required this.userName,
    required this.bus,
    required this.date,
    //required this.meal,
    required this.seatId,
  });

  Future<void> _contactTransport() async {
    const phoneNumber = 'tel:+8801937313639';
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

    DateTime? currentTimestamp;

    if (date != null) {
      try {
        currentTimestamp = DateFormat('dd-MM-yyyy HH:mm:ss').parse(date!);
        print("Parsed date: $currentTimestamp");
      } catch (e) {
        currentTimestamp = DateTime.now();
         print("Error parsing date: $e. Using current date: $currentTimestamp");
      }
    } else {
      currentTimestamp = DateTime.now();
    }

    final expiryDate = currentTimestamp.add(const Duration(days: 1));
    print("Expiry date: $expiryDate");

    ThemeData theme = AppTheme.getTheme(userDept);

    String qrData =
        '$seatId\n$userId\n${bus.toUpperCase()}\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(currentTimestamp)}\n${DateFormat('dd-MM-yyyy HH:mm:ss').format(expiryDate)}';

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: onLogout,
        theme: theme,
        title: 'Bus Token',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Text(
                  '${bus.toUpperCase()} TOKEN',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  bus.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd-MM-yyyy').format(currentTimestamp),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Scan this QR Code',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
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
                    fontSize: screenWidth * 0.06,
                  ),
                ),
                Text(
                  userId,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  '*Bus tokens will be available for 24 hours from the time of booking',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.035,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: theme.primaryColor,
                //     foregroundColor: Colors.white,
                //     padding: EdgeInsets.symmetric(
                //       horizontal: screenWidth * 0.15,
                //       vertical: screenHeight * 0.02,
                //     ),
                //   ),
                //   child: Text(
                //     'Return to Tokens',
                //     style: TextStyle(
                //         fontSize: screenWidth * 0.045),
                //   ),
                // ),
                TextButton(
                  onPressed: _contactTransport,
                  child: Text(
                    'Contact Transport Office',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

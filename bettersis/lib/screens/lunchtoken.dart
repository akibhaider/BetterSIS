import 'package:flutter/material.dart';
import '../modules/qr_code_widget.dart';
import 'package:intl/intl.dart';

class LunchToken extends StatelessWidget {
  final String userId;

  const LunchToken({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Generate current timestamp and expiry date
    final currentTimestamp = DateTime.now();
    final expiryDate = currentTimestamp.add(const Duration(days: 1));
    
    // Format the data to be stored in the QR code
    String qrData = '$userId\n${DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTimestamp)}\n${DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Token'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrCodeWidget(qrData: qrData), 
            const SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white, 
              ),
              child: const Text('Return to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

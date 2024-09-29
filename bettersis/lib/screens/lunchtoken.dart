import 'package:flutter/material.dart';
import '../modules/qr_code_widget.dart'; // Import the QrCodeWidget

class LunchToken extends StatelessWidget {
  final String userId;

  const LunchToken({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Token'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrCodeWidget(userId: userId), 
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

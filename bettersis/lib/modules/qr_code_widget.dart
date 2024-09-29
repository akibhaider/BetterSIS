import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class QrCodeWidget extends StatelessWidget {
  final String userId;

  const QrCodeWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Generate current timestamp and expiry date
    final currentTimestamp = DateTime.now();
    final expiryDate = currentTimestamp.add(const Duration(days: 1));
    
    // Format the data to be stored in the QR code
    String qrData = 'ID: $userId\nTimestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTimestamp)}\nExpiry: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate)}';

    return Center(
      child: QrImageView(
        data: qrData, 
        version: QrVersions.auto,
        size: 200.0, 
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class QrCodeWidget extends StatelessWidget {
  final String qrData;

  const QrCodeWidget({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    

    return Center(
      child: QrImageView(
        data: qrData, 
        version: QrVersions.auto,
        size: 200.0, 
      ),
    );
  }
}

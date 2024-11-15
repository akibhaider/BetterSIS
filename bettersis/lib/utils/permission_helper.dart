import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<bool> requestStoragePermission(BuildContext context) async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isRestricted || status.isLimited) {
      var result = await Permission.storage.request();
      if (result.isGranted) return true;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context);
    }

    return false;
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Storage permission is needed to download files. Please enable it in app settings.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Go to Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

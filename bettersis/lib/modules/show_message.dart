import 'package:flutter/material.dart';

class ShowMessage {
  static void success(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outlined, color: Colors.green),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

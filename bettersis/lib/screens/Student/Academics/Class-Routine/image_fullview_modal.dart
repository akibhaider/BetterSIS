import 'package:flutter/material.dart';

class ImageFullviewModal extends StatelessWidget {
  final String imageUrl;

  const ImageFullviewModal({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ));
  }
}

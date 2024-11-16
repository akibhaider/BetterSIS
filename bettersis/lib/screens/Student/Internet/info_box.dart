import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const InfoBox(
      {super.key,
      required this.label,
      required this.value,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final fontSizeMedium = screenWidth * 0.035;
    final fontSizeSmall = screenWidth * 0.03;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: screenWidth * 0.34,
          height: screenWidth * 0.069,
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSizeMedium,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Container(
          width: screenWidth * 0.34,
          height: screenWidth * 0.069,
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
            color: Colors.blueGrey[100],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSizeSmall,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

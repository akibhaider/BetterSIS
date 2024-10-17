import 'package:flutter/material.dart';

class SeatLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LegendItem(
            iconColor: Colors.black,
            label: 'Available',
            iconSize: screenWidth * 0.07,
            textSize: screenWidth * 0.04,
          ),
          LegendItem(
            iconColor: Colors.green,
            label: 'Selected',
            iconSize: screenWidth * 0.07,
            textSize: screenWidth * 0.04,
          ),
          LegendItem(
            iconColor: Colors.red,
            label: 'Occupied',
            iconSize: screenWidth * 0.07,
            textSize: screenWidth * 0.04,
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color iconColor;
  final String label;
  final double iconSize;
  final double textSize;

  const LegendItem({
    required this.iconColor,
    required this.label,
    required this.iconSize,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.event_seat, color: iconColor, size: iconSize),
        SizedBox(width: 4), 
        Text(
          label,
          style: TextStyle(fontSize: textSize),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class SeatLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LegendItem(iconColor: Colors.black, label: 'Available'),
        LegendItem(iconColor: Colors.green, label: 'Selected'),
        LegendItem(iconColor: Colors.red, label: 'Occupied'),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color iconColor;
  final String label;

  const LegendItem({required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.event_seat, color: iconColor),
        SizedBox(width: 2),
        Text(label),
      ],
    );
  }
}

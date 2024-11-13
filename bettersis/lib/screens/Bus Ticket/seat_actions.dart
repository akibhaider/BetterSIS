import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modules/Bus Ticket/seat_provider.dart';

class SeatActions extends StatelessWidget {
  final String userId;

  const SeatActions({super.key, required this.userId});
  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              print("Confirm button pressed");
              seatProvider
                  .confirmSelection(userId); // Pass the userId dynamically
            },
            child: Text('CONFIRM'),
          ),
          // Example usage in a widget's button
          // ElevatedButton(
          //   onPressed: () {
          //     Provider.of<SeatProvider>(context, listen: false)
          //         .generateAdditionalSeats(30);
          //   },
          //   child: Text("Generate 30 Seats"),
          // ),

          OutlinedButton(
            onPressed: () {
              print("Cancel button pressed");
              seatProvider.cancelSelection();
            },
            child: Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}

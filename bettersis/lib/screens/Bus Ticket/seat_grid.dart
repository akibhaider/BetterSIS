import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modules/Bus Ticket/seat_provider.dart';

class SeatGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);

    if (seatProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final seats = seatProvider.seats;
    if (seats.isEmpty) {
      return Center(child: Text('No seats available.'));
    }

    // Split seats into 4 columns, ensuring a gap between the second and third columns
    final seatColumns = _splitIntoColumns(seats.entries.toList());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First set of 2 columns
          _buildSeatColumn(seatColumns[0], context), // Column 1
          SizedBox(width: 10), // Small space between columns
          _buildSeatColumn(seatColumns[1], context), // Column 2

          SizedBox(width: 30), // Gap between two sets of columns

          // Second set of 2 columns
          _buildSeatColumn(seatColumns[2], context), // Column 3
          SizedBox(width: 10), // Small space between columns
          _buildSeatColumn(seatColumns[3], context), // Column 4
        ],
      ),
    );
  }

  // Split seats into 4 columns for the grid layout
  List<List<MapEntry<String, dynamic>>> _splitIntoColumns(List<MapEntry<String, dynamic>> seats) {
    List<List<MapEntry<String, dynamic>>> columns = [[], [], [], []];

    for (int i = 0; i < seats.length; i++) {
      // Distribute seats across the 4 columns
      columns[i % 4].add(seats[i]);
    }

    return columns;
  }

  // Helper method to build a column of seats
  Widget _buildSeatColumn(List<MapEntry<String, dynamic>> seats, BuildContext context) {
    return Column(
      children: [
        for (var seatEntry in seats) ...[
          _buildSeat(seatEntry, context),
          SizedBox(height: 10), // Space between seats vertically
        ],
      ],
    );
  }

  // Helper method to build individual seat widgets
  Widget _buildSeat(MapEntry<String, dynamic> seatEntry,BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);
    final seatKey = seatEntry.key;
    final seatData = seatEntry.value;

    return GestureDetector(
      onTap: seatData['available']
          ? () => seatProvider.toggleSeatSelection(seatKey) // Replace with your selection logic
          : null,
      child: Container(
        width: 50, // Adjust seat size
        height: 50,
        decoration: BoxDecoration(
          color: seatData['available']
              ? seatData['selected'] == true
                  ? Colors.green
                  : Colors.black
              : Colors.red,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Icon(Icons.event_seat, color: Colors.white),
        ),
      ),
    );
  }
}

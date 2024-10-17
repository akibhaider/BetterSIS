import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modules/Bus Ticket/seat_provider.dart';

class SeatGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust seat size based on screen width
    final seatSize = screenWidth * 0.1;
    final seatSpacing = screenWidth * 0.025;
    final gapBetweenSets = screenWidth * 0.07;

    if (seatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final seats = seatProvider.seats;
    if (seats.isEmpty) {
      return const Center(child: Text('No seats available.'));
    }

    // Split seats into 4 columns
    final seatColumns = _splitIntoColumns(seats.entries.toList());

    return SingleChildScrollView( // Make the grid scrollable
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column( // Wrap in Column to support vertical scroll
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First set of 2 columns
                _buildSeatColumn(seatColumns[0], context, seatSize, seatSpacing),
                SizedBox(width: seatSpacing),
                _buildSeatColumn(seatColumns[1], context, seatSize, seatSpacing),

                SizedBox(width: gapBetweenSets), // Gap between two sets of columns

                // Second set of 2 columns
                _buildSeatColumn(seatColumns[2], context, seatSize, seatSpacing),
                SizedBox(width: seatSpacing),
                _buildSeatColumn(seatColumns[3], context, seatSize, seatSpacing),
              ],
            ),
          ],
        ),
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
  Widget _buildSeatColumn(
    List<MapEntry<String, dynamic>> seats,
    BuildContext context,
    double seatSize,
    double seatSpacing,
  ) {
    return Column(
      children: [
        for (var seatEntry in seats) ...[
          _buildSeat(seatEntry, context, seatSize),
          SizedBox(height: seatSpacing), // Space between seats vertically
        ],
      ],
    );
  }

  // Helper method to build individual seat widgets
  Widget _buildSeat(
    MapEntry<String, dynamic> seatEntry,
    BuildContext context,
    double seatSize,
  ) {
    final seatProvider = Provider.of<SeatProvider>(context);
    final seatKey = seatEntry.key;
    final seatData = seatEntry.value;

    return GestureDetector(
      onTap: seatData['available']
          ? () => seatProvider.toggleSeatSelection(seatKey)
          : null,
      child: Container(
        width: seatSize,
        height: seatSize,
        decoration: BoxDecoration(
          color: seatData['available']
              ? seatData['selected'] == true
                  ? Colors.green
                  : Colors.black
              : Colors.red,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Icon(Icons.event_seat, color: Colors.white, size: seatSize * 0.5),
        ),
      ),
    );
  }
}

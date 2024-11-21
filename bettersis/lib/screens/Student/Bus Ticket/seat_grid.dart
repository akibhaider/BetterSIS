import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../modules/Bus Ticket/seat_provider.dart';

class SeatGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

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

    final seatColumns = _splitIntoColumns(seats);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSeatColumn(seatColumns[0], context, seatSize, seatSpacing),
                SizedBox(width: seatSpacing),
                _buildSeatColumn(seatColumns[1], context, seatSize, seatSpacing),
                SizedBox(width: gapBetweenSets),
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
  
  List<List<Map<String, dynamic>>> _splitIntoColumns(List<Map<String, dynamic>> seats) {
    List<List<Map<String, dynamic>>> columns = [[], [], [], []];
    for (int i = 0; i < seats.length; i++) {
      columns[i % 4].add(seats[i]);
    }
    return columns;
  }

  Widget _buildSeatColumn(
    List<Map<String, dynamic>> seats,
    BuildContext context,
    double seatSize,
    double seatSpacing,
  ) {
    return Column(
      children: [
        for (var seat in seats) ...[
          _buildSeat(seat, context, seatSize),
          SizedBox(height: seatSpacing),
        ],
      ],
    );
  }

  Widget _buildSeat(
    Map<String, dynamic> seatData,
    BuildContext context,
    double seatSize,
  ) {
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);
    final seatIndex = seatProvider.seats.indexOf(seatData);

    return GestureDetector(
      onTap: seatData['status'] == true
          ? () => seatProvider.toggleSeatSelection(seatIndex)
          : null,
      child: Container(
        width: seatSize,
        height: seatSize,
        decoration: BoxDecoration(
          color: seatData['status'] == false
              ? Colors.red // Confirmed as unavailable
              : seatData['selected'] == true
                  ? Colors.green // Temporarily selected by user
                  : Colors.black, // Available for selection
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Icon(Icons.event_seat, color: Colors.white, size: seatSize * 0.5),
        ),
      ),
    );
  }
}

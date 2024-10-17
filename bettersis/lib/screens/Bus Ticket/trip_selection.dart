import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

import 'seat_selection_screen.dart';

import 'package:intl/intl.dart';

class TripSelectionPage extends StatefulWidget {
  final String userId;
  final String userDept;
  final VoidCallback onLogout;

  const TripSelectionPage({super.key, required this.userId, required this.onLogout, required this.userDept});
  @override
  _TripSelectionPageState createState() => _TripSelectionPageState();
}

class _TripSelectionPageState extends State<TripSelectionPage> {
  String selectedTripType = 'One Way'; // Default trip type
  DateTime today = DateTime.now(); // Store the current date

  @override
  void initState() {
    super.initState();
    _scheduleDateUpdate(); // Schedule automatic update at 11:59 PM
  }

  // This method updates the trip date at midnight (11:59 PM)
  void _scheduleDateUpdate() {
    final DateTime nextDay = DateTime(today.year, today.month, today.day + 1);
    final Duration timeToMidnight = nextDay.difference(DateTime.now());

    Future.delayed(timeToMidnight, () {
      setState(() {
        today = DateTime.now(); // Update to the new day
      });
      _scheduleDateUpdate(); // Reschedule for the next midnight
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    String formattedDate =
        DateFormat('MMMM d, yyyy').format(today); // Format as "Month day, Year"

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'TRANSPORTATION',
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Set the background color

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "TRANSPORTATION",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[200],
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("BALANCE", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 5),
                      Icon(Icons.visibility_off, color: Colors.white, size: 16),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[200],
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                  ),
                ),
              ),
            ),
            _buildDropdown(
              context,
              label: "TRIP TYPE",
              value: selectedTripType,
              items: ['One Way', 'Round Trip'],
              onChanged: (String? newValue) {
                setState(() {
                  selectedTripType = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDateSelector(formattedDate), // Show today's date
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedTripType.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  SeatSelectionScreen(userId: widget.userId,userDept: widget.userDept,onLogout: widget.onLogout,),
                      ),
                    );
                  }
                },
                child: Text("CONFIRM"),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the trip type dropdown
  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(color: const Color.fromARGB(255, 3, 189, 240), fontSize: 16),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 223, 230, 255),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: SizedBox(),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to display the selected trip date (today's date)
  Widget _buildDateSelector(String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "TRIP DATE:",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              formattedDate,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

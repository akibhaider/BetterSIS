import 'package:bettersis/modules/Bus%20Ticket/seat_provider.dart';
import 'package:bettersis/modules/Bus%20Ticket/trip_provider.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'seat_selection_screen.dart';
import 'dart:async';

class TripSelectionPage extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;

  const TripSelectionPage(
      {super.key,
      required this.userId,
      required this.onLogout,
      required this.userDept,
      required this.userName});

  @override
  _TripSelectionPageState createState() => _TripSelectionPageState();
}

class _TripSelectionPageState extends State<TripSelectionPage> {
  double owPrice = 30.0;
  double rtPrice = 60.0;
  double tripCost = 0.0;
  String? selectedTripType = null;
  DateTime today = DateTime.now();

  // late SeatProvider _seatProvider;

  @override
  void initState() {
    super.initState();
    _scheduleDateUpdate();
    _scheduleTimeUpdates();
    // Initialize the SeatProvider
    //_seatProvider = SeatProvider(widget.userId, selectedTripType ?? '');
  }

  void _scheduleDateUpdate() {
    final DateTime nextDay = DateTime(today.year, today.month, today.day + 1);
    final Duration timeToMidnight = nextDay.difference(DateTime.now());

    Future.delayed(timeToMidnight, () {
      setState(() {
        today = DateTime.now();
      });
      _scheduleDateUpdate();
    });
  }

  void _scheduleTimeUpdates() {
    // Update every minute to check if we've crossed 7:00 AM
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        // This will rebuild the UI and update the dropdown options
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    ThemeData theme = AppTheme.getTheme(widget.userDept);
    String formattedDate = DateFormat('MMMM d, yyyy').format(today);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'TRANSPORTATION',
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                // child: Text(
                //   "TRANSPORTATION",
                //   style: TextStyle(
                //     color: theme.primaryColor,
                //     fontSize: screenWidth * 0.06,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ),
            ),
            // Center(
            //   child: Container(
            //     margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            //     child: TextButton(
            //       onPressed: () {},
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Text("BALANCE",
            //               style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: screenWidth * 0.05)),
            //           SizedBox(width: screenWidth * 0.02),
            //           Icon(Icons.visibility_off,
            //               color: Colors.white, size: screenWidth * 0.05),
            //         ],
            //       ),
            //       style: TextButton.styleFrom(
            //         backgroundColor: theme.primaryColor,
            //         padding: EdgeInsets.symmetric(
            //           vertical: screenHeight * 0.02,
            //           horizontal: screenWidth * 0.05,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            _buildDropdown(
              context,
              label: "TRIP TYPE",
              value: selectedTripType,
              items: [
                'One Way (Uttara - IUT)',
                'One Way (IUT - Uttara)',
                'Round Trip'
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedTripType = newValue!;
                });
                // Provider.of<TripProvider>(context, listen: false)
                //     .selectTripType(newValue!);
                if (selectedTripType == 'One Way (Uttara - IUT)' ||
                    selectedTripType == 'One Way (IUT - Uttara)') {
                  tripCost = owPrice;
                } else {
                  tripCost = rtPrice;
                }
              },
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildDateSelector(formattedDate, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.05),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedTripType!.isNotEmpty &&
                      selectedTripType != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatSelectionScreen(
                          userId: widget.userId,
                          userDept: widget.userDept,
                          userName: widget.userName,
                          onLogout: widget.onLogout,
                          tripCost: tripCost,
                          selectedType: selectedTripType!,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "CONFIRM",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),

            ///For Testing Purposes
//             SizedBox(height: 20), // Add spacing between buttons
// Center(
//   child: ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.amber, // Use a different color for testing button
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//     ),
//     onPressed: () {
//       // Call the test function
//       _seatProvider.testResetNow();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Seat reset test triggered! Check console logs.')),
//       );
//     },
//     child: Text(
//       "TEST RESET SEATS (TYPE 1)",
//       style: TextStyle(
//         fontSize: screenWidth * 0.04,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   ),
// ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    // Filter out Uttara-IUT option after 7:00 AM
    DateTime now = DateTime.now();
    bool isAfter7AM = now.hour > 7 || (now.hour == 7 && now.minute > 0);

    List<String> availableItems = isAfter7AM
        ? items.where((item) => item != 'One Way (Uttara - IUT)').toList()
        : items;

    // Reset selected value if it's no longer available
    if (isAfter7AM && value == 'One Way (Uttara - IUT)') {
      Future.microtask(() {
        setState(() {
          selectedTripType = null;
        });
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButton<String>(
            value: value,
            dropdownColor: theme.primaryColor,
            isExpanded: true,
            underline: SizedBox(),
            items: availableItems.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item,
                    style: TextStyle(
                        fontSize: screenWidth * 0.04, color: Colors.white)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
      String formattedDate, double screenWidth, double screenHeight) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "TRIP DATE:",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.02,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

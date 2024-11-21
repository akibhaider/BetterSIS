import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'seat_actions.dart';
import 'seat_grid.dart';
import 'seat_legend.dart';
import '../../../modules/Bus Ticket/seat_provider.dart';
import '../../../modules/Bus Ticket/trip_provider.dart';

class SeatSelectionScreen extends StatelessWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;
  final double tripCost;
  final String selectedType;

  const SeatSelectionScreen({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
    required this.tripCost,
    required this.selectedType, required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    ThemeData theme = AppTheme.getTheme(userDept);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SeatProvider>(
          create: (_) => SeatProvider(userId)..fetchSeats(),
        ),
        ChangeNotifierProvider<TripProvider>(
          create: (_) => TripProvider(),
        ),
      ],
      child: Scaffold(
        drawer: CustomAppDrawer(theme: theme),
        appBar: BetterSISAppBar(
          onLogout: onLogout,
          theme: theme,
          title: 'TRANSPORTATION',
        ),
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: SeatLegend(),
              ),
              Expanded(
                child: SeatGrid(),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Consumer2<SeatProvider, TripProvider>(
                  builder: (context, seatProvider, tripProvider, child) {
                    final seatCount = seatProvider.getSelectedSeatCount();
                    final totalCost = seatCount * tripCost;
                    
                    
                    
                     return Column(
                      
                     children: [
                       Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          child: Icon(
                            // Icon for meal
                            Icons.directions_bus, // Icon for bus
                            color: Colors.white,
                          ),
                        ),
                        title: Text('Trip Cost'),
                        // subtitle: Text(type == 'meal'
                        //     ? 'Meal Token'
                        //     : 'Transportation'),
                        trailing: Text('\$${totalCost.toString()}'
                            // '৳${transactions[index]['amount'].toStringAsFixed(2)}',
                            // style: const TextStyle(
                            //     fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                      ),
                      
                    ),
                    //     Text(
                    //       'Total Cost: \$${totalCost.toString()}',
                    //       style: TextStyle(
                    //         fontSize: screenWidth * 0.05,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    SeatActions(userId: userId, totalCost: totalCost, selectedType: selectedType, userName: userName,userDept: userDept),
                      ],
                     );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

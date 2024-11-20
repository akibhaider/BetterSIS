import 'package:bettersis/screens/Student/Bus%20Ticket/busToken.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../modules/Bus Ticket/seat_provider.dart';
import '../Smart Wallet/smart_wallet.dart';

class SeatActions extends StatelessWidget {
  final String userId;
  final String userDept;
  final String userName;
  final double totalCost;
  final String selectedType;
  smartWalletPage walletP = smartWalletPage();

  SeatActions({super.key, required this.userId, required this.totalCost, required this.selectedType, required this.userDept, required this.userName});
  
  Future<void> buyTicket(BuildContext context, String userID, double tokenCost, int seatCount) async {
    print('\n\n\n\n$userID - $tokenCost - $seatCount\n\n\n');
    SeatProvider seatPage = SeatProvider(userID);
    //final seatProvider = Provider.of<SeatProvider>(context);
    double currentBalance = await walletP.getBalance(userID);

    if(currentBalance < tokenCost) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Insufficient Funds"),
            content: const Text("You do not have enough balance in your Smart Wallet."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }

    else{
      bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Purchase"),
            content: Text("You are about to purchase $seatCount token(s) for a total of $tokenCost Taka. Do you want to continue?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm purchase
                  
                },
                child: const Text("Confirm"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Cancel purchase
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );

      if (confirmation) {
        //seatPage.confirmSelection(userId);
        // Deduct the token cost from the current balance
        double newBalance = currentBalance - tokenCost;

        // Update the balance in Firestore
        await walletP.updateBalance(userID, newBalance);

        // Log the transaction in Firestore
        await walletP.addTransaction(userID, 'Bus - $selectedType', tokenCost, 'Transportation');

        // Show success dialog before navigation
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Purchase Successful"),
              content: const Text("Your token purchase was successful."),
              actions: [
                TextButton(
                  onPressed: () {

                    print('\n\nOK\n\n');
                    Navigator.of(context).pop();
                    
                        final selectedSeatIndices = seatPage.getSelectedSeatIndices();
              final seatId = selectedSeatIndices.isNotEmpty ? selectedSeatIndices.toString() : 'N/A';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusToken(
                    userId: userId,
                    userDept: userDept, // Replace with actual department
                    onLogout: () {}, // Replace with actual logout function
                    userName: userName, // Replace with actual user name
                    bus: 'Bus', // Replace with actual bus name
                    date: DateTime.now().toString(), // Replace with actual date
                    seatId: seatId,
                  ),
                ),
              ); 
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);
    // final seatCount = seatProvider.getSelectedSeatCount();
    // final tripCost = tripProvider.getTripCost(seatCount);
    final numSeat = seatProvider.getSelectedSeatCount();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              print("Confirm button pressed $totalCost");
              
              buyTicket(context, userId, totalCost, numSeat);
               seatProvider.confirmSelection(userId);// Pass the userId dynamically
              // final selectedSeatIndices = seatProvider.getSelectedSeatIndices();
              // final seatId = selectedSeatIndices.isNotEmpty ? selectedSeatIndices.toString() : 'N/A';

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => LunchToken(
              //       userId: userId,
              //       userDept: userDept, // Replace with actual department
              //       onLogout: () {}, // Replace with actual logout function
              //       userName: userName, // Replace with actual user name
              //       bus: 'Bus', // Replace with actual bus name
              //       date: DateTime.now().toString(), // Replace with actual date
              //       seatId: seatId,
              //     ),
              //   ),
              // ); 
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

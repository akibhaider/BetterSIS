import 'package:flutter/material.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
//import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import '../../../modules/bettersis_appbar.dart';

class SmartWallet extends StatefulWidget {
  //const SmartWallet({super.key});
  final String userId;
  final String userDept;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const SmartWallet({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<SmartWallet> createState() => smartWalletPage();
}

class smartWalletPage extends State<SmartWallet> {
  double balance = 0.0;
  int totalTransactions = 0;
  List<Map<String, dynamic>> transactions = [];
  //SmartWalletPage({super.key});
  bool isLoading = true;
  final ValueNotifier<bool> isBalanceVisible = ValueNotifier(false);

  Future<void> fetchData() async {
    //first balance is fetched.

    try{
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Finance')
          .doc(widget.userId)
          .get();
      
      if(userDoc.exists){
        setState(() {
          balance = (userDoc['Balance'] is int)
                ? (userDoc['Balance'] as int).toDouble()
                : userDoc['Balance'];
        });
      }

      print('\n\n\n');
      print(balance);
      print('\n\n\n');      
      // Fetch all the documents from the "Transactions" subcollection
      QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
          .collection('Finance')
          .doc(widget.userId)
          .collection('Transactions')
          .get();
      
      List<Map<String, dynamic>> tempTransactions = [];

      for (var transaction in transactionsSnapshot.docs) {
        tempTransactions.add(transaction.data() as Map<String, dynamic>);
      }

      setState(() {
        transactions = tempTransactions;
        totalTransactions = transactions.length;
        isLoading = false;
      });

      // int i=6;
      // print('\n\n\n\n');
      // for(var trans in transactions){
      //   print('${trans['title']} - ${trans['timestamp']} - ${trans['amount']}\n\n');
      //   i--;
      //   if(i==0) break;
      // }print('\n----- soort-----\n');

      sortTransactionsByTimestamp();
    }

    catch(error){
      print("Error fetching data");
    }
  }

  Future<void> addTransaction(String userID, String title, double amount, String type) async {

    await FirebaseFirestore.instance.collection('Finance').doc(userID).collection('Transactions').add({
      'title': title,
      'type': type,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  Future<void> updateBalance(String userID, double newBalance) async {
    try {
      print('\n\n\n\n\n\n\n\n\n');
      print(balance);
      print('\n\n\n\n\n\n\n\n\n');
      // Update the balance in Firestore
      await FirebaseFirestore.instance
          .collection('Finance')
          .doc(userID)
          .update({
            'Balance': newBalance,
          });
    } catch (error) {
      print('Error updating balance: $error');
    }
  }

  Future<void> addMoney(double amount) async {
    try {
      // Update the balance by adding the specified amount
      setState(() {
        balance += amount;
      });

      // Also update the balance in Firestore
      await FirebaseFirestore.instance
          .collection('Finance')
          .doc(widget.userId)
          .update({
            'Balance': balance,
          });

      // After adding money, add a transaction to the user's list
      await addTransaction(widget.userId, 'Money Added', amount, 'add');

      print('Money added successfully');
    } catch (error) {
      print('Error adding money: $error');
    }
  }

  Future<double> getBalance(String userID) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Finance')
          .doc(userID) // use userID passed as parameter
          .get();

      if (userDoc.exists) {
        // Safely access 'Balance' and convert it
        var balanceData = userDoc.data() as Map<String, dynamic>?; // Ensure it's a Map
        if (balanceData != null) {
          var balance = balanceData['Balance'];
          if (balance is int) {
            return balance.toDouble(); // Convert int to double
          } else if (balance is double) {
            return balance; // Return as is if already a double
          }
        }
      } else {
        print('User document does not exist.');
      }
    } catch (error) {
      print('Error fetching balance: $error');
    }
    
    return 0.0; // Default return if not found or an error occurs
  }

  void sortTransactionsByTimestamp() {
    transactions.sort((a, b) {
      // Compare the 'timestamp' field for sorting
      Timestamp timestampA = a['timestamp'];
      Timestamp timestampB = b['timestamp'];
      
      // Return the comparison result (-1, 0, 1)
      return timestampB.compareTo(timestampA);
    });
  }

  void transDetails(int index){
    print('\n\n\nView pressed\n\n\n');
    final transaction = transactions[index];
    final DateTime dateTime = transaction['timestamp'].toDate();
    final String formattedDate = DateFormat('dd/MM/yy hh:mm a').format(dateTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(transaction['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${transaction['type']}'),
              Text('Amount: ৳${transaction['amount']}'),
              Text('Date: $formattedDate'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void addMoneyToWallet(){
    print('Add Money pressed');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final String name = widget.userName;
    final String studentId = widget.userId;
    //final String email = widget.userEmail;
    //final double balance = 4180.20;

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      backgroundColor: theme.primaryColor,
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Smart Wallet',
      ),

      floatingActionButton: !isLoading
        ? Container(
          decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: FloatingActionButton.extended(
                onPressed: addMoneyToWallet,
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white, // White circle
                      radius: screenWidth * 0.04, // Adjust the radius for the circle size
                      child: Image.asset(
                        'assets/bKash.png',
                        height: screenWidth * 0.05, // Icon size
                        width: screenWidth * 0.05,
                        //fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                  "Add Money",
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                  ),
                ),
                ],
                ),
                //icon: const Icon(Icons.check),
                backgroundColor: theme.primaryColor,
              ),
        )
        : null,
      body: isLoading
      ? const Center(child: CircularProgressIndicator(color: Colors.white),)
      : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Section
          /*const CircleAvatar(
            radius: 40.0,
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Placeholder image
          ),*/
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            studentId,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          // Text(
          //   email,
          //   style: const TextStyle(color: Colors.white70, fontSize: 16),
          // ),
          const SizedBox(height: 5),
          // Balance Section
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  Text(
                    'BALANCE',
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold),
                  ),
                  
                  GestureDetector(
                    onTap: () {
                      isBalanceVisible.value = !isBalanceVisible.value;
                    },
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isBalanceVisible,
                      builder: (context, value, child) {
                        return Text(
                          value
                              ? '৳${balance.toStringAsFixed(2)}' // Show balance
                              : '****', // Hide balance
                          style: TextStyle(
                            color: theme.secondaryHeaderColor,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),

                  // Text(

                  //   '৳${balance.toStringAsFixed(2)}',
                  //   style: TextStyle(
                  //       color: theme.secondaryHeaderColor,
                  //       fontSize: screenWidth * 0.05,
                  //       fontWeight: FontWeight.bold),
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Transactions Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    child: Text(
                      'LATEST TRANSACTIONS',
                      style: TextStyle(
                          color: theme.secondaryHeaderColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  //const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        String type = transactions[index]['type'];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.primaryColor,
                                  child: Icon(
                                    type == 'meal' ? Icons.restaurant_menu : Icons.directions_bus,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(transactions[index]['title']),
                                subtitle: Text(type == 'meal' ? 'Meal Token' : 'Transportation'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: transactions[index]['title'] == 'Refund'
                                        ? Colors.green
                                        : const Color.fromARGB(255, 219, 58, 47),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '৳${transactions[index]['amount'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: transactions[index]['title'] == 'Refund'
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      transDetails(index);
                                    },
                                    icon: const Icon(Icons.info_outline, size: 18),
                                    label: Text(
                                      'View Details >>',
                                      style: TextStyle(color: theme.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
      
    );
  }
}
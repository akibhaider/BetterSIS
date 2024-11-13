import 'package:flutter/material.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
//import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import '../../modules/bettersis_appbar.dart';

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

      print('\n\n\n\n\n\n\n\n\n');
    print(balance);
    print('\n\n\n\n\n\n\n\n\n');      
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
      });   

          /*if(totalTransactions > 4){
            transactions = transactions.sublist(totalTransactions - 4);
          }*/
        
      }
    }

    catch(error){
      print("Error fetching data");
    }
  }

Future<void> addTransaction(String userID, String title, double amount, String type) async {
  print('\n\n\n\n\n\n\n\n\n');
    print('UUUUUUUUUUUUUUUUUUUU');
    print('\n\n\n\n\n\n\n\n\n');
  
  await FirebaseFirestore.instance.collection('Finance').doc(userID).collection('Transactions').add({
    'title': title,
    'type': type,
    'amount': amount,
    'timestamp': FieldValue.serverTimestamp(),
  });

  print('\n\n\n\n\n\n\n\n\n');
    print('UUUUUUUUUUUUUUUUUUUU');
    print('\n\n\n\n\n\n\n\n\n');
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
    final String email = widget.userEmail;
    //final double balance = 4180.20;


    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      backgroundColor: theme.primaryColor,
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Smart Wallet',
      ),
      body: Column(
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
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Balance Section
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                children: [
                  Text(
                    'BALANCE',
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(

                    '৳${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: theme.secondaryHeaderColor,
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Add Money Button
          Container(
            width: screenWidth *0.6,
            child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.secondaryHeaderColor,
              padding: EdgeInsets.symmetric(vertical: screenHeight *0.02),
              //maximumSize: const Size(150, 50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/bKash.png',
                  height: screenWidth * 0.1, // Responsive height
                  width: screenWidth * 0.1,
                ),
                const SizedBox(width: 10),
                Text(
              "Add Money",
              style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: theme.secondaryHeaderColor,
              ),
            ),
            ],
            ),

          ),
          ),

          const SizedBox(height: 20),

          // Transactions Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  Text(
                    'LATEST TRANSACTIONS',
                    style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: totalTransactions,
                      itemBuilder: (context, index) {
                        String type = transactions[index]['type'];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                type == 'meal'
                                    ? Icons.restaurant_menu // Icon for meal
                                    : Icons.directions_bus, // Icon for bus
                                color: Colors.white,
                              ),
                            ),
                            title: Text(transactions[index]['title']),
                            subtitle: Text(type == 'meal'
                                ? 'Meal Token'
                                : 'Transportation'),
                            trailing: Text(
                              '৳${transactions[index]['amount'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  /*TextButton(
                    onPressed: () {
                      // Placeholder for "View More" action
                    },
                    child: const Text(
                      'View More >>',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  // Mock user data (will be replaced by Firebase data later)

  // Mock transaction data
  double balance = 0.0;
  int totalTransactions = 0;
  List<Map<String, dynamic>> transactions = [];

   //ThemeData theme = AppTheme.getTheme(widget.userData['dept']);

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
          balance = userDoc['Balance'];
          transactions = List<Map<String, dynamic>>.from(
            userDoc['Transactions'] ?? [],
          );
          totalTransactions = transactions.length;

          /*if(totalTransactions > 4){
            transactions = transactions.sublist(totalTransactions - 4);
          }*/
        });
      }
    }

    catch(error){
      print("Error fetching data");
    }
  }

  Future<void> addTransaction(String title, double amount, String type) async {
  try {
    Map<String, dynamic> newTransaction = {
      'title': title,
      'amount': amount,
      'type': type, // 'add', 'meal', 'transport', etc.
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() {
      transactions.add(newTransaction);
      totalTransactions = transactions.length;
    });

    // Update the transaction list in Firestore
    await FirebaseFirestore.instance
        .collection('Finance')
        .doc(widget.userId)
        .update({
          'Transactions': FieldValue.arrayUnion([newTransaction]),
        });

    print('Transaction added successfully');
    } catch (error) {
      print('Error adding transaction: $error');
    }
  }


  Future<void> updateBalance(double amount, bool isAdded) async {
  try {
    // Update balance based on whether amount is added or deducted
    setState(() {
      if (isAdded) {
        balance += amount; // Add the amount to the balance
      } else {
        balance -= amount; // Deduct the amount from the balance
      }
    });

    // Update the balance in Firestore
    await FirebaseFirestore.instance
        .collection('Finance')
        .doc(widget.userId)
        .update({
          'Balance': balance,
        });

    // Add a transaction to reflect this change
    /*String transactionTitle = isAdded ? 'Money Added' : 'Money Deducted';
    String transactionType = isAdded ? 'add' : 'deduct';
    
    await addTransaction(transactionTitle, amount, transactionType);

    print('Balance updated and transaction added successfully');*/
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
    await addTransaction('Money Added', amount, 'add');

    print('Money added successfully');
  } catch (error) {
    print('Error adding money: $error');
  }
}

Future<double> getBalance() async {
  //fetchData();
  final walletRef = FirebaseFirestore.instance.collection('Finance').doc(widget.userId);

  final walletSnap = await walletRef.get();

  if(walletSnap.exists) {
    return walletSnap.data()?['balance']?.toDouble() ?? 0.0;
  }

  else{
    return 0.0;
  }
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
    final double balance = 4180.20;


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
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'BALANCE',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '৳${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 6, 55, 139),
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Add Money Button
          Container(
            width: MediaQuery.of(context).size.width *0.8,
            child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.secondaryHeaderColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              //maximumSize: const Size(150, 50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/bKash.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 10),
                Text(
              "Add Money",
              style: TextStyle(
                  fontSize: 20,
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
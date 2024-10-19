import 'dart:convert';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InternetBody extends StatefulWidget {
  final String userName;
  final String userId;
  final String userDept;

  const InternetBody(
      {super.key,
      required this.userName,
      required this.userId,
      required this.userDept});

  @override
  State<InternetBody> createState() => _InternetBodyState();
}

class _InternetBodyState extends State<InternetBody> {
  bool isLoading = true;
  String totalUsage = "12,000";
  List<List<String>> usageDetails = [];

  Future<void> _fetchInternetUsage(username, password) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/get-usage/');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var minutesUsed = data['usage'][0].toString();
        if (minutesUsed.length == 4) {
          minutesUsed =
              '${minutesUsed[0]},${minutesUsed[1]}${minutesUsed[2]}${minutesUsed[3]}';
        } else if (minutesUsed.length == 5) {
          minutesUsed =
              '${minutesUsed[0]}${minutesUsed[1]},${minutesUsed[2]}${minutesUsed[3]}${minutesUsed[4]}';
        }

        setState(() {
          totalUsage = minutesUsed;
          usageDetails = List<List<String>>.from(
            data['usage'].sublist(1).map((item) => List<String>.from(item)),
          ).reversed.toList();
        });
      } else {
        print("Failed to fetch data");
        setState(() {
          totalUsage = "12,000";
        });
      }
    } catch (error) {
      print("Error: $error");
      setState(() {
        totalUsage = "12,000";
      });
    }
  }

  Future<void> fetchInternetCredsFromFirestore() async {
    setState(() {
      isLoading = true;
      print("Loading Started");
    });

    final documentRef =
        FirebaseFirestore.instance.collection('Internet').doc(widget.userId);

    try {
      final documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;

        final username = data['username'];
        final password = data['password'];

        await _fetchInternetUsage(username, password);
      } else {
        print('No such document exists!');
      }
    } catch (e) {
      print('Error fetching tokens: $e');
    } finally {
      setState(() {
        isLoading = false;
        print("Loading Ended");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInternetCredsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Stack(
      children: [
        Container(
          color: theme.primaryColor,
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 26.0),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontSize: 0.062 * screenWidth,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.userId,
                      style: TextStyle(
                        fontSize: 0.037 * screenWidth,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Minutes Used',
                      style: TextStyle(
                        fontSize: screenWidth * 0.037,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryHeaderColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            totalUsage,
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.w700,
                              color: theme.secondaryHeaderColor,
                            ),
                          ),
                          Text(
                            'out of',
                            style: TextStyle(
                              fontSize: screenWidth * 0.046,
                              fontWeight: FontWeight.w700,
                              color: theme.secondaryHeaderColor,
                            ),
                          ),
                          Text(
                            '12,000',
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.w700,
                              color: theme.secondaryHeaderColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: fetchInternetCredsFromFirestore,
                child: Container(
                  padding: const EdgeInsets.only(top: 26, bottom: 16),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      Text(
                        "REFRESH",
                        style: TextStyle(
                          fontSize: 0.032 * screenWidth,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02),
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
                        'USAGE HISTORY',
                        style: TextStyle(
                          color: theme.secondaryHeaderColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: usageDetails.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.01),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  foregroundColor: theme.primaryColor,
                                  backgroundColor: Colors.transparent,
                                  child: const Icon(Icons.circle_rounded),
                                ),
                                title: Text(usageDetails[index][4]),
                                subtitle:
                                    Text(usageDetails[index][0].split(' ')[0]),
                                trailing: Text(
                                  '${usageDetails[index][2].split(' ')[0]} Mins',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View More >>',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          Container(
            width: screenWidth,
            height: screenHeight,
            color: Colors.black.withOpacity(0.6),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

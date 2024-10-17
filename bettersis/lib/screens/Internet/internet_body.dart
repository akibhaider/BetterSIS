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
  Map<String, String>? creds = {"username": "", "password": ""};
  String totalUsage = "10,780";
  List<List<String>> usageDetails = [];
  List<Map<String, String>> history = [
    {"location": "Library", "duration": "69"},
    {"location": "AB2", "duration": "112"},
    {"location": "CDS", "duration": "15"}
  ];

  Future<void> _fetchInternetUsage(username, password) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/api/get-usage/'); // Replace with your actual Django URL

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          totalUsage = data['usage'][0].toString();
          usageDetails = List<List<String>>.from(
            data['usage'].sublist(1).map((item) => List<String>.from(item)),
          );
          print("totalUsage: $totalUsage");
          print("usageDetails: $usageDetails");
        });
      } else {
        print("else case");
        setState(() {
          totalUsage = "10,780";
        });
      }
    } catch (error) {
      print("error case");
      setState(() {
        totalUsage = "10,780";
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Future<void> fetchInternetCredsFromFirestore() async {
      setState(() {
        isLoading = true;
      });

      final documentRef =
          FirebaseFirestore.instance.collection('Internet').doc(widget.userId);

      try {
        final documentSnapshot = await documentRef.get();

        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;

          final username = data['username'];
          final password = data['password'];

          print('Username: $username, Password: $password');
          setState(() {
            isLoading = false;
          });
        } else {
          print('No such document exists!');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching tokens: $e');
      }
    }

    fetchInternetCredsFromFirestore();
    _fetchInternetUsage("tanjeebmeheran", "yahbaby");
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Container(
      color: theme.primaryColor,
      width: screenWidth,
      height: screenHeight,
      child: Column(
        children: [
          /*
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
            child: Text(
              'IUT INTERNET',
              style: TextStyle(
                fontSize: 0.032 * screenSize.width,
                fontWeight: FontWeight.w500,
                color: theme.secondaryHeaderColor,
              ),
            ),
          ),
          */
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26.0),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: const Column(
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 0.062 * screenSize.width,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.userId,
                  style: TextStyle(
                    fontSize: 0.037 * screenSize.width,
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
          Container(
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
                      fontSize: 0.032 * screenSize.width,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  )
                ],
              )),
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
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.circle_rounded),
                            ),
                            title: Text(
                                'IUTWLAN - ${history[index]['location']!}'),
                            trailing: Text(
                              '${history[index]['duration']!} Mins',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }
}

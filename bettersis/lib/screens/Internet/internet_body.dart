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
    {
      "location": "Library",
      "duration": "69",
    },
    {
      "location": "AB2",
      "duration": "112",
    },
    {
      "location": "CDS",
      "duration": "15",
    }
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

    return Container(
      color: theme.primaryColor,
      width: screenSize.width,
      height: screenSize.height,
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
            child: Column(
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
            margin: EdgeInsets.symmetric(horizontal: 0.083 * screenSize.width),
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.grey.withOpacity(0.5), // Shadow color with opacity
                  spreadRadius: 5, // How much the shadow spreads
                  blurRadius: 7, // How blurry the shadow is
                  offset: const Offset(0,
                      3), // The position of the shadow (horizontal, vertical)
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Minutes Used',
                  style: TextStyle(
                    fontSize: 0.037 * screenSize.width,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryHeaderColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalUsage,
                        style: TextStyle(
                          fontSize: 0.083 * screenSize.width,
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryHeaderColor,
                        ),
                      ),
                      Text(
                        'out of',
                        style: TextStyle(
                          fontSize: 0.046 * screenSize.width,
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryHeaderColor,
                        ),
                      ),
                      Text(
                        '12,000',
                        style: TextStyle(
                          fontSize: 0.083 * screenSize.width,
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
              onTap: () {
                _fetchInternetUsage("tanjeebmeheran", "yahbaby");
              },
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
                          fontSize: 0.032 * screenSize.width,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ))),
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
                    'USAGE HISTORY',
                    style: TextStyle(
                        color: theme.secondaryHeaderColor,
                        fontSize: 0.041 * screenSize.width,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 0.023 * screenSize.width),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 0.037 * screenSize.width),
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

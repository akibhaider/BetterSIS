import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class ResourceFrontPage extends StatefulWidget {
  final String userName;
  final String userId;
  final String userDept;

  const ResourceFrontPage(
      {super.key,
      required this.userName,
      required this.userId,
      required this.userDept});

  @override
  State<ResourceFrontPage> createState() => _ResourceFrontPageState();
}

class _ResourceFrontPageState extends State<ResourceFrontPage> {
  final List<String> buttonLabels = [
    'PREVIOUS QUESTIONS',
    'BROWSE BOOKS',
    'BORROWED BOOKS',
    'E-THESIS',
    'UPCOMING EVENTS',
    'LIBRARY TEAM',
    'NOTICES',
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(
                vertical: 20, horizontal: 0.037 * screenSize.width),
            child: Column(
              children: buttonLabels.map((label) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.primaryColor, // Button background color
                      minimumSize: Size(screenSize.width, 50), // Button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              print("Contact Library Management tapped!");
            },
            child: Text(
              'Contact Library Management',
              style: TextStyle(
                fontSize: 16,
                color: theme.secondaryHeaderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
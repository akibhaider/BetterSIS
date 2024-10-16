import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class InternetBody extends StatefulWidget {
  final String userId;
  final String userDept;

  const InternetBody({super.key, required this.userId, required this.userDept});

  @override
  State<InternetBody> createState() => _InternetBodyState();
}

class _InternetBodyState extends State<InternetBody> {
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
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
            child: const Text(
              'IUT INTERNET',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF18A0D9),
              ),
            ),
          ),
          SizedBox(
            width: screenSize.width,
            height: screenSize.height * 0.01,
          ),
        ],
      ),
    );
  }
}

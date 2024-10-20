import 'package:bettersis/modules/custom_button.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class AcademicsFrontPage extends StatefulWidget {
  final String userId;
  final String userDept;

  const AcademicsFrontPage(
      {super.key, required this.userId, required this.userDept});

  @override
  State<AcademicsFrontPage> createState() => _AcademicsFrontPageState();
}

class _AcademicsFrontPageState extends State<AcademicsFrontPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;
    final double buttonWidth = screenSize.width * 0.8;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(
                vertical: 40, horizontal: 0.1 * screenSize.width),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                    label: 'COURSE REGISTRATION',
                    onPressed: () {},
                    bgColor: theme.secondaryHeaderColor.withOpacity(0.5),
                    width: buttonWidth),
                CustomButton(
                    label: 'COURSE FEEDBACK',
                    onPressed: () {},
                    bgColor: theme.secondaryHeaderColor.withOpacity(0.5),
                    width: buttonWidth),
                const SizedBox(height: 50),
                CustomButton(
                    label: 'CLASS ROUTINE',
                    onPressed: () {},
                    bgColor: theme.primaryColor,
                    width: buttonWidth),
                CustomButton(
                    label: 'ENROLLED COURSES',
                    onPressed: () {},
                    bgColor: theme.primaryColor,
                    width: buttonWidth),
                CustomButton(
                    label: 'CLASSROOM CODES',
                    onPressed: () {},
                    bgColor: theme.primaryColor,
                    width: buttonWidth),
                CustomButton(
                    label: 'UPCOMING EXAMS',
                    onPressed: () {},
                    bgColor: theme.primaryColor,
                    width: buttonWidth),
              ],
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }
}

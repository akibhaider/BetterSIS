import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import '../../../modules/Admit Card/generate-admit-card.dart';

class AdmitCard extends StatefulWidget {
  final VoidCallback onLogout;
  final String userId;
  final String userDept;
  final String userName;
  final String userProgram;
  final String userSemester;

  const AdmitCard({
    super.key,
    required this.onLogout,
    required this.userDept,
    required this.userId,
    required this.userName,
    required this.userProgram,
    required this.userSemester,
  });

  @override
  State<AdmitCard> createState() => _AdmitCardState();
}

class _AdmitCardState extends State<AdmitCard> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout, 
        theme: theme, 
        title: "Admit Card",
      ),
      body: GenerateAdmitCard(
        semester: (int.parse(widget.userSemester[0]) % 2 == 0)
            ? "Summer"
            : "Winter",
        examination: "Mid",
        userDept: widget.userDept,
        userId: widget.userId,
        userName: widget.userName,
        userProgram: widget.userProgram,
        userSemester: widget.userSemester
      ),
    );
  }
}

import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Academics/academics_front_page.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class Academics extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userProgram;
  final String userSemester;
  final String userSection;
  final VoidCallback onLogout;

  const Academics({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userProgram,
    required this.userSemester,
    required this.userSection,
    required this.onLogout,
  });

  @override
  State<Academics> createState() => _AcademicsState();
}

class _AcademicsState extends State<Academics> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Academics',
      ),
      body: AcademicsFrontPage(
        userId: widget.userId,
        userDept: widget.userDept,
        userProgram: widget.userProgram,
        userSemester: widget.userSemester,
        userSection: widget.userSection,
        onLogout: widget.onLogout,
      ),
    );
  }
}

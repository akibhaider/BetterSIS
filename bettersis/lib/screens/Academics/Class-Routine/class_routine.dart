import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class ClassRoutine extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userSemester;
  final String userSection;
  final VoidCallback onLogout;

  const ClassRoutine({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userSemester,
    required this.userSection,
    required this.onLogout,
  });

  @override
  State<ClassRoutine> createState() => _ClassRoutineState();
}

class _ClassRoutineState extends State<ClassRoutine> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
        drawer: CustomAppDrawer(theme: theme),
        appBar: BetterSISAppBar(
          onLogout: widget.onLogout,
          theme: theme,
          title: 'Class Routine',
        ),
        body: const Text("ClassRoutine"));
  }
}

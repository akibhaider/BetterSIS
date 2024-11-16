import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class Classes extends StatefulWidget {
  final String userId;
  final String userDept;
  final VoidCallback onLogout;

  const Classes(
      {super.key,
      required this.userDept,
      required this.userId,
      required this.onLogout});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
          onLogout: widget.onLogout, theme: theme, title: "Classes"),
    );
  }
}

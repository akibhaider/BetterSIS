import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class ClassroomCodes extends StatefulWidget {
  final String userId;
  final String userDept;
  final VoidCallback onLogout;

  const ClassroomCodes({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
  });

  @override
  State<ClassroomCodes> createState() => _ClassroomCodesState();
}

class _ClassroomCodesState extends State<ClassroomCodes> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
        drawer: CustomAppDrawer(theme: theme),
        appBar: BetterSISAppBar(
          onLogout: widget.onLogout,
          theme: theme,
          title: 'Classroom Codes',
        ),
        body: const Text("ClassroomCodes"));
  }
}

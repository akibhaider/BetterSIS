import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CourseRegistration extends StatefulWidget {
  final String userId;
  final String userDept;
  final VoidCallback onLogout;

  const CourseRegistration({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
  });

  @override
  State<CourseRegistration> createState() => _CourseRegistrationState();
}

class _CourseRegistrationState extends State<CourseRegistration> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
        drawer: CustomAppDrawer(theme: theme),
        appBar: BetterSISAppBar(
          onLogout: widget.onLogout,
          theme: theme,
          title: 'Course Registration',
        ),
        body: const Text("CourseRegistration"));
  }
}

import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InternetUsage extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;

  const InternetUsage({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userName,
    required this.onLogout,
  });

  @override
  State<InternetUsage> createState() => _InternetUsageState();
}

class _InternetUsageState extends State<InternetUsage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
          onLogout: widget.onLogout, theme: theme, title: "Internet Usage"),
    );
  }
}

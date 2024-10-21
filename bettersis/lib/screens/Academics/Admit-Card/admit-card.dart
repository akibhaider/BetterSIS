import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import '../../../modules/Admit Card/generate-admit-card.dart';

class AdmitCard extends StatefulWidget {
  final VoidCallback onLogout;
  final String userId;
  final String userDept;

  const AdmitCard({
    super.key,
    required this.onLogout,
    required this.userDept,
    required this.userId,
  });

  @override
  State<AdmitCard> createState() => _AdmitCardState();
}

class _AdmitCardState extends State<AdmitCard> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Admit Card',
      ),
      drawer: CustomAppDrawer(theme: theme),
      body: GenerateAdmitCard(
        userId: widget.userId,
        userName: 'S.M. Tanjeeb Meheran Rohan',  // Dummy data for testing
        userDept: widget.userDept,
        programme: 'BSc in CSE',
        semester: 'Fifth',
        registeredCourses: [
          'CSE 4501: Operating Systems',
          'CSE 4503: Microprocessor and Assembly Language',
          'CSE 4511: Computer Networks',
          'CSE 4513: Software Engineering and Object Oriented Design',
          'CSE 4519: Simulation and Modeling',
          'Math 4541: Multivariable Calculus and Complex Variables',
        ],
      ),
    );
  }
}

import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/modules/loading_spinner.dart';
import 'package:bettersis/screens/Student/Academics/Classroom-Codes/show_code.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassroomCodes extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userProgram;
  final String userSemester;
  final String userSection;
  final VoidCallback onLogout;

  const ClassroomCodes({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userProgram,
    required this.userSemester,
    required this.userSection,
    required this.onLogout,
  });

  @override
  State<ClassroomCodes> createState() => _ClassroomCodesState();
}

class _ClassroomCodesState extends State<ClassroomCodes> {
  bool isLoading = true;
  List<Map<String, String>> classList = [];

  Future<void> fetchClassroomCodesFromFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      final documentRef = FirebaseFirestore.instance
          .collection('Classroom')
          .doc(widget.userDept);
      final documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        List<Map<String, String>> data = [];
        Map<String, dynamic>? programData =
            documentSnapshot.data()?[widget.userProgram];

        if (programData != null && programData[widget.userSection] is List) {
          data = List<Map<String, String>>.from(programData[widget.userSection]
              .map((item) => Map<String, String>.from(item)));
        }

        if (data.isNotEmpty) {
          setState(() {
            classList = data;
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClassroomCodesFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double fontSizeLarge = 0.05 * screenWidth;
    final double fontSizeSmall = 0.04 * screenWidth;

    return Scaffold(
        drawer: CustomAppDrawer(theme: theme),
        appBar: BetterSISAppBar(
          onLogout: widget.onLogout,
          theme: theme,
          title: 'Classroom Codes',
        ),
        body: Stack(children: [
          Container(
              color: theme.primaryColor,
              width: screenWidth,
              height: screenHeight,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 26.0),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    children: [
                      Text(
                        'BSc in ${widget.userProgram.toUpperCase()}',
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Semester: ${widget.userSemester}',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Section: ${widget.userSection}',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google Classroom Codes',
                          style: TextStyle(
                            color: theme.secondaryHeaderColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: classList.length,
                            itemBuilder: (context, index) {
                              final classroom = classList[index];
                              return ShowCode(
                                  classroom: classroom, theme: theme);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ])),
          if (isLoading) const LoadingSpinner(),
        ]));
  }
}

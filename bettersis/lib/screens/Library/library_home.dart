import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:flutter/material.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:bettersis/screens/Library/question_bank.dart';
import 'package:bettersis/screens/Library/course_materials.dart';
import 'package:bettersis/screens/Library/course_outline.dart';

class Library extends StatelessWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;
  final ThemeData themeData;

  const Library({
    Key? key,
    required this.userId,
    required this.userDept,
    required this.userName,
    required this.onLogout,
    required this.themeData,
  }) : super(key: key);
  //
  // void _navigateToSection(BuildContext context, String section) {
  //   if (section == "Question_Bank") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => QuestionBankPage()),
  //     );
  //   } else if (section == "Course_Materials") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => CourseMaterialsPage()),
  //     );
  //   } else if (section == "Course_Outlines") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => CourseOutlinePage()),
  //     );
  //   } else {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => SectionPage(sectionTitle: section)),
  //     );
  //   }
  // }
  void _navigateToSection(BuildContext context, String section) {
    if (section == "Question_Bank") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuestionBankPage()),
      );
    } else if (section == "Course_Materials") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CourseMaterialsPage()),
      );
    } else if (section == "Course_Outlines") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseOutlinePage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SectionPage(sectionTitle: section)),
      );
    }
  }


  Widget _buildResourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double fontSize,
    Color? backgroundColor,
    double? iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: backgroundColor ?? themeData.primaryColor,
            child: Icon(icon, color: Colors.white, size: iconSize ?? 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(userDept);
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375;

    return Scaffold(
      appBar: BetterSISAppBar(onLogout: onLogout, theme: theme, title: "Library"),
      drawer: CustomAppDrawer(theme: theme),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = screenWidth > 600 ? 4 : 2;
                return Column(
                  children: [
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 30,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildResourceButton(
                          icon: Icons.library_books,
                          label: "Question Bank",
                          onTap: () => _navigateToSection(context, "Question_Bank"),
                          fontSize: 14 * scaleFactor,
                        ),
                        _buildResourceButton(
                          icon: Icons.book,
                          label: "Course Materials",
                          onTap: () => _navigateToSection(context, "Course_Materials"),
                          fontSize: 14 * scaleFactor,
                        ),
                        _buildResourceButton(
                          icon: Icons.note,
                          label: "Course Outlines",
                          onTap: () => _navigateToSection(context, "Course_Outlines"),
                          fontSize: 14 * scaleFactor,
                        ),

                        _buildResourceButton(
                          icon: Icons.sticky_note_2,
                          label: "Lecture Notes",
                          onTap: () => _navigateToSection(context, "Lecture_Notes"),
                          fontSize: 14 * scaleFactor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: _buildResourceButton(
                        icon: Icons.engineering,
                        label: "Engineering Village",
                        onTap: () => _navigateToSection(context, "Engineering_Village"),
                        fontSize: 16 * scaleFactor,
                        // backgroundColor: theme.accentColor,
                        iconSize: 40,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionPage extends StatelessWidget {
  final String sectionTitle;

  const SectionPage({Key? key, required this.sectionTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section"),
      ),
      body: Center(
        child: Text(
          "Content for $sectionTitle",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

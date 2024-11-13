import 'package:bettersis/modules/custom_button.dart';
import 'package:bettersis/screens/Academics/Admit-Card/admit-card.dart';
import 'package:bettersis/screens/Academics/Announcment/announcement.dart';
import 'package:bettersis/screens/Academics/Class-Routine/class_routine.dart';
import 'package:bettersis/screens/Academics/Classroom-Codes/classroom_codes.dart';
import 'package:bettersis/screens/Academics/Course-Feedback/course_feedback.dart';
import 'package:bettersis/screens/Academics/Course-Registration/course_registration.dart';
import 'package:bettersis/screens/Academics/Enrolled-Courses/enrolled_courses.dart';
import 'package:bettersis/screens/Academics/Upcoming-Exams/upcoming_exams.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class AcademicsFrontPage extends StatefulWidget {
  final String userName;
  final String userId;
  final String userDept;
  final String userProgram;
  final String userSemester;
  final String userSection;
  final String imageUrl;
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const AcademicsFrontPage({
    super.key,
    required this.userName,
    required this.userId,
    required this.userDept,
    required this.userProgram,
    required this.userSemester,
    required this.userSection,
    required this.imageUrl,
    required this.userData,
    required this.onLogout,
  });

  @override
  State<AcademicsFrontPage> createState() => _AcademicsFrontPageState();
}

class _AcademicsFrontPageState extends State<AcademicsFrontPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;
    final double buttonSize = screenSize.width * 0.3; // Circular button size

    List<Map<String, dynamic>> options = [
      {
        'label': 'Course Registration',
        'icon': Icons.app_registration,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseRegistration(
                onLogout: widget.onLogout,
                userData: widget.userData,
                imageUrl: widget.imageUrl,
              ),
            ),
          );
        }
      },
      {
        'label': 'Course Feedback',
        'icon': Icons.feedback,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseFeedback(
                onLogout: widget.onLogout,
                userId: widget.userId,
                userDept: widget.userDept,
              ),
            ),
          );
        }
      },
      {
        'label': 'Download Admit Card',
        'icon': Icons.card_membership,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdmitCard(
                onLogout: widget.onLogout,
                userId: widget.userId,
                userDept: widget.userDept,
                userName: widget.userName,
                userProgram: widget.userProgram,
                userSemester: widget.userSemester,
              ),
            ),
          );
        }
      },
      {
        'label': 'Announcements',
        'icon': Icons.announcement,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Announcement(
                isCr: widget.userData['cr'],
                userId: widget.userId,
                userName: widget.userName,
                userDept: widget.userDept,
                userProgram: widget.userProgram,
                userSection: widget.userSection,
                userSemester: widget.userSemester,
                onLogout: widget.onLogout,
              ),
            ),
          );
        }
      },
      {
        'label': 'Class Routine',
        'icon': Icons.schedule,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassRoutine(
                onLogout: widget.onLogout,
                userId: widget.userId,
                userDept: widget.userDept,
                userProgram: widget.userProgram,
                userSemester: widget.userSemester,
                userSection: widget.userSection,
              ),
            ),
          );
        }
      },
      {
        'label': 'Enrolled Courses',
        'icon': Icons.book,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnrolledCourses(
                onLogout: widget.onLogout,
                userId: widget.userId,
                userDept: widget.userDept,
              ),
            ),
          );
        }
      },
      {
        'label': 'Classroom Codes',
        'icon': Icons.code,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassroomCodes(
                onLogout: widget.onLogout,
                userId: widget.userId,
                userDept: widget.userDept,
                userProgram: widget.userProgram,
                userSemester: widget.userSemester,
                userSection: widget.userSection,
              ),
            ),
          );
        }
      },
      {
        'label': 'Upcoming Exams',
        'icon': Icons.event,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpcomingExams(
                onLogout: widget.onLogout,
                userId: widget.userId,
                userDept: widget.userDept,
              ),
            ),
          );
        }
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenSize.height * 0.03,
            left: screenSize.width * 0.05,
            right: screenSize.width * 0.05,
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return _buildCircularButton(
                theme: theme,
                label: options[index]['label'],
                icon: options[index]['icon'],
                onPressed: options[index]['onPressed'],
                buttonSize: buttonSize,
              );
            },
          ),
        ),
      ),
    );
  }

  // Method to build a circular button with icon and label
  Widget _buildCircularButton({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required double buttonSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: buttonSize * 0.4,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: buttonSize * 0.12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

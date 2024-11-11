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

    // Button size adjustments
    final double buttonWidth = screenSize.width * 0.75;
    final double buttonHeight = screenSize.height * 0.07;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.05,
              horizontal: screenSize.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomButton(
                label: 'COURSE REGISTRATION',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CourseRegistration(
                              onLogout: widget.onLogout,
                              userId: widget.userId,
                              userDept: widget.userDept,
                            )),
                  );
                },
                bgColor: theme.secondaryHeaderColor.withOpacity(0.5),
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
              CustomButton(
                label: 'COURSE FEEDBACK',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CourseFeedback(
                              onLogout: widget.onLogout,
                              userId: widget.userId,
                              userDept: widget.userDept,
                            )),
                  );
                },
                bgColor: theme.secondaryHeaderColor.withOpacity(0.5),
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
              CustomButton(
                label: 'DOWNLOAD ADMIT CARD',
                onPressed: () {
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
                            )),
                  );
                },
                bgColor: theme.secondaryHeaderColor.withOpacity(0.5),
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
              const SizedBox(height: 30), // Adjust the space between sections
              CustomButton(
                label: 'ANNOUNCEMENTS',
                onPressed: () {
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
                              onLogout: widget.onLogout,
                            )),
                  );
                },
                bgColor: theme.primaryColor,
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
              CustomButton(
                label: 'CLASS ROUTINE',
                onPressed: () {
                  // Uncomment and implement class routine logic
                },
                bgColor: theme.primaryColor,
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
              CustomButton(
                label: 'ENROLLED COURSES',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EnrolledCourses(
                              onLogout: widget.onLogout,
                              userId: widget.userId,
                              userDept: widget.userDept,
                            )),
                  );
                },
                bgColor: theme.primaryColor,
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
              CustomButton(
                label: 'CLASSROOM CODES',
                onPressed: () {
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
                            )),
                  );
                },
                bgColor: theme.primaryColor,
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
              CustomButton(
                label: 'UPCOMING EXAMS',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpcomingExams(
                              onLogout: widget.onLogout,
                              userId: widget.userId,
                              userDept: widget.userDept,
                            )),
                  );
                },
                bgColor: theme.primaryColor,
                borderColor: theme.secondaryHeaderColor,
                width: buttonWidth
              ),
            ],
          ),
        ),
      ),
    );
  }
}

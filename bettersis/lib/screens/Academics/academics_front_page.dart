import 'package:bettersis/modules/custom_button.dart';
import 'package:bettersis/screens/Academics/Class-Routine/class_routine.dart';
import 'package:bettersis/screens/Academics/Classroom-Codes/classroom_codes.dart';
import 'package:bettersis/screens/Academics/Course-Feedback/course_feedback.dart';
import 'package:bettersis/screens/Academics/Course-Registration/course_registration.dart';
import 'package:bettersis/screens/Academics/Enrolled-Courses/enrolled_courses.dart';
import 'package:bettersis/screens/Academics/Upcoming-Exams/upcoming_exams.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class AcademicsFrontPage extends StatefulWidget {
  final String userId;
  final String userDept;
  final VoidCallback onLogout;

  const AcademicsFrontPage({
    super.key,
    required this.userId,
    required this.userDept,
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
    final double buttonWidth = screenSize.width * 0.8;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(
                vertical: 40, horizontal: 0.1 * screenSize.width),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                    label: 'COURSE REGISTRATION',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CourseRegistration(
                                onLogout: widget.onLogout,
                                userId: widget.userId,
                                userDept: widget.userDept)),
                      );
                    },
                    bgColor: theme.secondaryHeaderColor.withOpacity(0.5),
                    borderColor: theme.secondaryHeaderColor,
                    width: buttonWidth),
                CustomButton(
                    label: 'COURSE FEEDBACK',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CourseFeedback(
                                onLogout: widget.onLogout,
                                userId: widget.userId,
                                userDept: widget.userDept)),
                      );
                    },
                    bgColor: theme.secondaryHeaderColor.withOpacity(0.5),
                    borderColor: theme.secondaryHeaderColor,
                    width: buttonWidth),
                const SizedBox(height: 50),
                CustomButton(
                    label: 'CLASS ROUTINE',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClassRoutine(
                                onLogout: widget.onLogout,
                                userId: widget.userId,
                                userDept: widget.userDept)),
                      );
                    },
                    bgColor: theme.primaryColor,
                    borderColor: theme.secondaryHeaderColor,
                    width: buttonWidth),
                CustomButton(
                    label: 'ENROLLED COURSES',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EnrolledCourses(
                                onLogout: widget.onLogout,
                                userId: widget.userId,
                                userDept: widget.userDept)),
                      );
                    },
                    bgColor: theme.primaryColor,
                    borderColor: theme.secondaryHeaderColor,
                    width: buttonWidth),
                CustomButton(
                    label: 'CLASSROOM CODES',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClassroomCodes(
                                onLogout: widget.onLogout,
                                userId: widget.userId,
                                userDept: widget.userDept)),
                      );
                    },
                    bgColor: theme.primaryColor,
                    borderColor: theme.secondaryHeaderColor,
                    width: buttonWidth),
                CustomButton(
                    label: 'UPCOMING EXAMS',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpcomingExams(
                                onLogout: widget.onLogout,
                                userId: widget.userId,
                                userDept: widget.userDept)),
                      );
                    },
                    bgColor: theme.primaryColor,
                    borderColor: theme.secondaryHeaderColor,
                    width: buttonWidth),
              ],
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }
}

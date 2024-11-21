import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Teacher/Classes/course_details.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Classes extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const Classes({super.key, required this.userData, required this.onLogout});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  List<Map<String, dynamic>> theoryCourses = [];
  List<Map<String, dynamic>> labCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      String dept = widget.userData['dept'];
      List<String> courses = (widget.userData['courses'] as List<dynamic>).cast<String>();

      for (String courseCode in courses) {
        String courseNumber = courseCode.split('-').last;
        String semesterNumber = courseNumber[1];

        // Fetch course data from Firestore
        DocumentSnapshot courseDoc = await FirebaseFirestore.instance
            .collection('Courses')
            .doc(dept)
            .collection(semesterNumber)
            .doc(courseCode)
            .get();

        if (courseDoc.exists) {
          Map<String, dynamic> courseData = courseDoc.data() as Map<String, dynamic>;
          String courseName = courseData['name'] ?? 'Unknown Course';

          bool isLab = int.parse(courseCode[courseCode.length - 1]) % 2 == 0;

          if (isLab) {
            labCourses.add({'code': courseCode, 'name': courseName});
          } else {
            theoryCourses.add({'code': courseCode, 'name': courseName});
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onCourseTap(String courseCode, String courseName) {
    Map<String, String> course = {
      'code': courseCode,
      'name': courseName
    };
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CourseDetails(
              onLogout: widget.onLogout,
              userDept: widget.userData['dept'],
              course: course)),
    );
  }

  Widget _buildCourseCard(String courseName, String courseCode, double fontSize) {
    return GestureDetector(
      onTap: () => _onCourseTap(courseCode, courseName),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseName,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                courseCode,
                style: TextStyle(fontSize: fontSize * 0.85, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseSection(String title, List<Map<String, dynamic>> courses, double fontSize, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize * 1.2, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return _buildCourseCard(
                courses[index]['name'],
                courses[index]['code'],
                fontSize,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.045;

    return Scaffold(
      appBar: BetterSISAppBar(
          onLogout: widget.onLogout, theme: theme, title: "Classes"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Theory Courses
                    if (theoryCourses.isNotEmpty)
                      _buildCourseSection('Theory Courses', theoryCourses, fontSize, theme.primaryColor),

                    // Display Lab Courses
                    if (labCourses.isNotEmpty)
                      _buildCourseSection('Lab Courses', labCourses, fontSize, theme.primaryColor),

                    if (theoryCourses.isEmpty && labCourses.isEmpty)
                      Center(
                        child: Text(
                          "No courses available for this semester.",
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

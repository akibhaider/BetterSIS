import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CourseDetails extends StatefulWidget {
  final Map<String, String> course;
  final String userDept;
  final VoidCallback onLogout;

  const CourseDetails({
    super.key,
    required this.course,
    required this.userDept,
    required this.onLogout,
  });

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudentsInCourse();
  }

  // Function to fetch students enrolled in the course
  Future<void> _fetchStudentsInCourse() async {
    try {
      List<Map<String, dynamic>> studentList = [];
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('type', isEqualTo: 'student')
          .get();

      String courseCode = widget.course['code']!;
      String courseNumber = courseCode.split('-').last;
      String semesterNumber = courseNumber[1];

      // Loop through all students and check if they are enrolled in this course
      for (var userDoc in userSnapshot.docs) {
        var userData = userDoc.data() as Map<String, dynamic>;

        // Check enrolled courses for this student
        DocumentSnapshot enrolledCourseDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userDoc.id)
            .collection('Enrolled Courses')
            .doc(semesterNumber)
            .get();

        if (enrolledCourseDoc.exists) {
          // Check if the student is enrolled in the current course
          DocumentSnapshot courseDoc = await enrolledCourseDoc.reference
              .collection('Course List')
              .doc(courseCode)
              .get();

          if (courseDoc.exists) {
            studentList.add({
              'name': userData['name'],
              'id': userData['id'],
              'email': userData['email'],
              'phone': userData['phone'],
              'cr': userData['cr'] ?? false, // Add the 'cr' field
            });
          }
        }
      }

      studentList
          .sort((a, b) => int.parse(a['id']).compareTo(int.parse(b['id'])));

      setState(() {
        students = studentList;
        filteredStudents = studentList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to handle searching, including CR keyword
  void _filterStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStudents = students;
      });
    } else if (query.toLowerCase() == 'cr') {
      setState(() {
        filteredStudents =
            students.where((student) => student['cr'] == true).toList();
      });
    } else {
      setState(() {
        filteredStudents = students
            .where((student) =>
                student['name'].toLowerCase().contains(query.toLowerCase()) ||
                student['id'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  // Function to handle launching email or phone URL
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to build student card
  Widget _buildStudentCard(Map<String, dynamic> student, Color color, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.045;

    return GestureDetector(
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: student['cr'] == true
              ? BorderSide(color: color, width: 3.0)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student['name'],
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'ID: ${student['id']}',
                style: TextStyle(
                  fontSize: fontSize * 0.85,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _launchUrl('mailto:${student['email']}');
                    },
                    child: Row(
                      children: [
                        Icon(Icons.email,
                            size: fontSize * 1.2, color: Colors.blue),
                        const SizedBox(width: 5),
                        Text(
                          student['email'],
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchUrl('tel:${student['phone']}');
                    },
                    child: Row(
                      children: [
                        Icon(Icons.phone,
                            size: fontSize * 1.2, color: Colors.green),
                        const SizedBox(width: 5),
                        Text(
                          student['phone'],
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    double fontSize = MediaQuery.of(context).size.width * 0.045;

    return Scaffold(
      appBar: BetterSISAppBar(
          onLogout: widget.onLogout,
          theme: theme,
          title: "Course Details (${widget.course['code']})"),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterStudents,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by name, ID, or "cr"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Student list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                    ? const Center(
                        child: Text('No students enrolled in this course.'))
                    : ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          return _buildStudentCard(
                              filteredStudents[index], theme.primaryColor, context);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

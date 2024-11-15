import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';

class CourseOutlinePage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const CourseOutlinePage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _CourseOutlinePageState createState() => _CourseOutlinePageState();
}

class _CourseOutlinePageState extends State<CourseOutlinePage> {
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;

  final List<String> programs = ['CSE', 'SWE'];
  final List<String> semesters = [
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'
  ];

  final List<String> semester1Courses = ['CSE 4105', 'CSE 4107', 'Math 4141', 'Phy 4141'];
  final List<String> semester2Courses = ['CSE 4203', 'CSE 4205', 'Math 4241', 'Phy 4241'];
  // Repeat for other semesters as needed

  List<String> currentCourses = [];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double paddingValue = screenWidth * 0.05;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Course Outlines',
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Program',
                border: OutlineInputBorder(),
              ),
              value: _selectedProgram,
              items: programs
                  .map((program) => DropdownMenuItem<String>(
                value: program,
                child: Text(program),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
              value: _selectedSemester,
              items: semesters
                  .map((semester) => DropdownMenuItem<String>(
                value: semester,
                child: Text(semester),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedCourse = null;

                  // Update courses based on the selected semester
                  switch (_selectedSemester) {
                    case 'Semester 1':
                      currentCourses = semester1Courses;
                      break;
                    case 'Semester 2':
                      currentCourses = semester2Courses;
                      break;
                  // Repeat for other semesters as needed
                    default:
                      currentCourses = [];
                  }
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
              value: _selectedCourse,
              items: currentCourses
                  .map((course) => DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                if (_selectedCourse != null) {
                  // Logic to handle outline download
                  print('Downloading outline for $_selectedCourse...');
                }
              },
              child: const Text('Download Outline'),
            ),
          ],
        ),
      ),
    );
  }
}

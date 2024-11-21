import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? imageUrl;

  final List<String> departments = ['cse', 'eee', 'mpe', 'cee', 'btm'];
  final List<String> programs = ['cse', 'swe'];
  final List<String> semesters = [
    'semester 1', 'semester 2', 'semester 3', 'semester 4',
    'semester 5', 'semester 6', 'semester 7', 'semester 8'
  ];

  final Map<String, List<String>> coursesBySemester = {
    'semester 1': ['cse 4105', 'cse 4107', 'math 4141', 'phy 4141'],
    'semester 2': ['cse 4203', 'cse 4205', 'math 4241', 'phy 4241'],
    'semester 3': ['cse 4301', 'cse 4303', 'math 4341', 'sta 4341'],
    // Add more semesters and their courses as needed
  };

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
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              value: _selectedDepartment,
              items: departments.map((department) => DropdownMenuItem<String>(
                value: department,
                child: Text(department),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                  _selectedProgram = null;
                  _selectedSemester = null;
                  _selectedCourse = null;
                  currentCourses = [];
                  imageUrl = null;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Program',
                border: OutlineInputBorder(),
              ),
              value: _selectedProgram,
              items: programs.map((program) => DropdownMenuItem<String>(
                value: program,
                child: Text(program),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                  _selectedSemester = null;
                  _selectedCourse = null;
                  currentCourses = [];
                  imageUrl = null;
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
              items: semesters.map((semester) => DropdownMenuItem<String>(
                value: semester,
                child: Text(semester),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedCourse = null;
                  currentCourses = coursesBySemester[_selectedSemester!] ?? [];
                  imageUrl = null;
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
              items: currentCourses.map((course) => DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
                fetchImageUrl();
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            if (imageUrl != null)
              Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton(
                    onPressed: downloadImage,
                    child: const Text('Download'),
                  ),
                ],
              )
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text('No Image Available'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchImageUrl() async {
    if (_selectedDepartment == null ||
        _selectedProgram == null ||
        _selectedSemester == null ||
        _selectedCourse == null) return;

    final path = 'Library/course_outlines/${_selectedDepartment!}/${_selectedProgram!}/${_selectedSemester!}/${_selectedCourse!}/${_selectedCourse!} co.png';
    print('Fetching image URL for path: $path');

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      imageUrl = await ref.getDownloadURL();
      setState(() {}); // Refresh UI to display the image
    } catch (e) {
      print('Error fetching image URL: $e');
      imageUrl = null;
      setState(() {});
    }
  }

  Future<void> downloadImage() async {
    if (imageUrl == null) return;

    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl!);
      final data = await ref.getData();
      // Here you can save `data` locally using a package like `path_provider` to access the device's file system.
      print('Image downloaded successfully');
    } catch (e) {
      print('Error downloading image: $e');
    }
  }
}

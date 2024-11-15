import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';

class QuestionBankPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const QuestionBankPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _QuestionBankPageState createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? _selectedExam;
  String? _selectedAcademicYear;
  String? imageUrl;

  final List<String> departments = ['cse', 'eee', 'mpe', 'cee', 'btm'];
  final Map<String, List<String>> departmentPrograms = {
    'cse': ['cse', 'swe'],
    'eee': ['eee'],
    'mpe': ['me', 'ipe'],
    'cee': ['cee'],
    'btm': ['btm'],
  };
  final List<String> semesters = [
    'semester 1', 'semester 2', 'semester 3', 'semester 4',
    'semester 5', 'semester 6', 'semester 7', 'semester 8'
  ];

  List<String> currentPrograms = [];
  List<String> currentCourses = [];
  final List<String> exams = ['quiz 1', 'mid', 'final'];
  final List<String> academicYears = ['swe_2020-21'];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double paddingValue = screenWidth * 0.05;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: "Question Bank",
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
                  currentPrograms = departmentPrograms[_selectedDepartment!] ?? [];
                  _selectedProgram = null;
                  _selectedSemester = null;
                  _selectedCourse = null;
                  currentCourses = [];
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
              items: currentPrograms.map((program) => DropdownMenuItem<String>(
                value: program,
                child: Text(program),
              )).toList(),
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
              items: semesters.map((semester) => DropdownMenuItem<String>(
                value: semester,
                child: Text(semester),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedCourse = null;
                  if (_selectedDepartment == 'cse' &&
                      _selectedProgram == 'cse' &&
                      _selectedSemester == 'semester 5') {
                    currentCourses = ['cse 4513'];
                  } else {
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
              items: currentCourses.map((course) => DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Exam',
                border: OutlineInputBorder(),
              ),
              value: _selectedExam,
              items: exams.map((exam) => DropdownMenuItem<String>(
                value: exam,
                child: Text(exam),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExam = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Academic Year',
                border: OutlineInputBorder(),
              ),
              value: _selectedAcademicYear,
              items: academicYears.map((year) => DropdownMenuItem<String>(
                value: year,
                child: Text(year),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAcademicYear = value;
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
        _selectedCourse == null ||
        _selectedExam == null ||
        _selectedAcademicYear == null) return;

    final path = 'Library/questions/${_selectedDepartment!}/${_selectedProgram!}/${_selectedSemester!}/${_selectedCourse!}/${_selectedExam!}/${_selectedAcademicYear!}.png';
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

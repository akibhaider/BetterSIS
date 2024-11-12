import 'dart:math';
import 'package:flutter/material.dart';

class LectureNotesPage extends StatefulWidget {
  @override
  _LectureNotesPageState createState() => _LectureNotesPageState();
}

class _LectureNotesPageState extends State<LectureNotesPage> {
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? _selectedBatch;
  String? _selectedTag;

  final List<String> programs = ['CSE', 'SWE'];
  final List<String> semesters = [
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'
  ];
  final List<String> batches = ['18', '19', '20'];

  final List<String> semester1Courses = ['CSE 4105', 'CSE 4107', 'Math 4141', 'Phy 4141'];
  final List<String> semester2Courses = ['CSE 4203', 'CSE 4205', 'Math 4241', 'Phy 4241'];
  List<String> currentCourses = [];

  // List of possible note owners
  final List<String> noteOwners = ['Navid', 'Sabbir', 'Evan', 'Ashnan', 'Sarah', 'Ayesha', 'John'];
  List<String> currentTags = [];

  // Method to generate random tags based on selected criteria
  void generateRandomTags() {
    currentTags = List<String>.from(noteOwners..shuffle()).take(4).toList(); // Take 4 random names
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double paddingValue = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecture Notes"),
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Program',
                border: const OutlineInputBorder(),
              ),
              value: _selectedProgram,
              items: programs.map((program) => DropdownMenuItem<String>(
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
              decoration: InputDecoration(
                labelText: 'Semester',
                border: const OutlineInputBorder(),
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

                  // Update courses based on the selected semester
                  switch (_selectedSemester) {
                    case 'Semester 1':
                      currentCourses = semester1Courses;
                      break;
                    case 'Semester 2':
                      currentCourses = semester2Courses;
                      break;
                    default:
                      currentCourses = [];
                  }
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Course',
                border: const OutlineInputBorder(),
              ),
              value: _selectedCourse,
              items: currentCourses.map((course) => DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                  _selectedTag = null;
                  generateRandomTags(); // Generate new random tags based on course selection
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Batch',
                border: const OutlineInputBorder(),
              ),
              value: _selectedBatch,
              items: batches.map((batch) => DropdownMenuItem<String>(
                value: batch,
                child: Text(batch),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBatch = value;
                  _selectedTag = null;
                  generateRandomTags(); // Refresh tags based on batch selection
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tag',
                border: const OutlineInputBorder(),
              ),
              value: _selectedTag,
              items: currentTags.map((tag) => DropdownMenuItem<String>(
                value: tag,
                child: Text(tag),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTag = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                if (_selectedCourse != null) {
                  print('Downloading notes for $_selectedCourse (Batch $_selectedBatch, Tag $_selectedTag)...');
                }
              },
              child: const Text('Download Notes'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:bettersis/modules/show_message.dart';

class LectureNotesPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const LectureNotesPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _LectureNotesPageState createState() => _LectureNotesPageState();
}

class _LectureNotesPageState extends State<LectureNotesPage> {
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? _selectedNote;
  String? imageUrl;

  final List<String> departments = ['cse', 'eee', 'cee', 'mpe', 'btm'];
  final List<String> programs = ['cse', 'swe'];
  final List<String> semesters = [
    'semester 1', 'semester 2', 'semester 3', 'semester 4',
    'semester 5', 'semester 6', 'semester 7', 'semester 8'
  ];

  final Map<String, List<String>> coursesBySemester = {
    'semester 5': ['cse 4501', 'cse 4503', 'cse 4511', 'cse 4513']
  };

  final Map<String, List<String>> notesByCourse = {
    'cse 4501': ['Aashnan os quiz 1', 'Ishmam os quiz 3'],
  };

  List<String> currentCourses = [];
  List<String> currentNotes = [];

  void _resetForm() {
    setState(() {
      _selectedDepartment = null;
      _selectedProgram = null;
      _selectedSemester = null;
      _selectedCourse = null;
      _selectedNote = null;
      imageUrl = null;
      currentCourses = [];
      currentNotes = [];
    });
  }

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
        title: 'Lecture Notes',
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: ListView(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Form'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              value: _selectedDepartment,
              items: departments
                  .map((department) => DropdownMenuItem<String>(
                value: department,
                child: Text(department.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                  _selectedProgram = null;
                  _selectedSemester = null;
                  _selectedCourse = null;
                  _selectedNote = null;
                  currentCourses = [];
                  currentNotes = [];
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
              items: programs
                  .map((program) => DropdownMenuItem<String>(
                value: program,
                child: Text(program.toUpperCase()),
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
                child: Text(semester.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedCourse = null;
                  _selectedNote = null;
                  currentCourses = coursesBySemester[_selectedSemester!] ?? [];
                  currentNotes = [];
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
                child: Text(course.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                  _selectedNote = null;
                  currentNotes = notesByCourse[_selectedCourse!] ?? [];
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              value: _selectedNote,
              items: currentNotes
                  .map((note) => DropdownMenuItem<String>(
                value: note,
                child: Text(note.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNote = value;
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
        _selectedNote == null) return;

    final path =
        'Library/notes/${_selectedDepartment!}/${_selectedProgram!}/${_selectedSemester!}/${_selectedCourse!}/${_selectedNote!}.png';
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
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to download files')),
        );
        return;
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ShowMessage.error(context, 'Failed to access storage');
        return;
      }

      final customPath = Directory(
          '${directory.parent.parent.parent.parent.path}/Download/BetterSIS/Notes');

      if (!await customPath.exists()) {
        await customPath.create(recursive: true);
      }

      final filePath = '${customPath.path}/${_selectedCourse}_${_selectedNote}.png';

      final response = await http.get(Uri.parse(imageUrl!));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ShowMessage.success(context, 'Note downloaded to: $filePath');
    } catch (e) {
      print('Error downloading image: $e');
      ShowMessage.error(context, 'Failed to download note');
    }
  }
}

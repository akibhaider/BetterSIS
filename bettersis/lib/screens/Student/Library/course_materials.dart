import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:bettersis/modules/show_message.dart';

class CourseMaterialsPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const CourseMaterialsPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _CourseMaterialsPageState createState() => _CourseMaterialsPageState();
}

class _CourseMaterialsPageState extends State<CourseMaterialsPage> {
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? _selectedBook;
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
  List<String> currentBooks = [];

  void _resetForm() {
    setState(() {
      _selectedDepartment = null;
      _selectedProgram = null;
      _selectedSemester = null;
      _selectedCourse = null;
      _selectedBook = null;
      imageUrl = null;
      currentPrograms = [];
      currentCourses = [];
      currentBooks = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Course Materials',
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
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
              decoration: InputDecoration(
                labelText: 'Department',
                border: const OutlineInputBorder(),
              ),
              value: _selectedDepartment,
              items: departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                  _selectedProgram = null;
                  currentPrograms = departmentPrograms[value!] ?? [];
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Program',
                border: const OutlineInputBorder(),
              ),
              value: _selectedProgram,
              items: currentPrograms.map((program) {
                return DropdownMenuItem<String>(
                  value: program,
                  child: Text(program),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                });
              },
              isExpanded: true,
              isDense: true,
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Semester',
                border: const OutlineInputBorder(),
              ),
              value: _selectedSemester,
              items: semesters.map((semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedCourse = null;
                  _selectedBook = null;

                  // Placeholder logic for updating courses based on selections
                  if (_selectedDepartment == 'cse' &&
                      _selectedProgram == 'cse' &&
                      _selectedSemester == 'semester 2') {
                    currentCourses = ['cse 4203'];
                  } else {
                    currentCourses = [];
                  }
                  currentBooks = []; // Reset books
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
              items: currentCourses.map((course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                  if (_selectedCourse == 'cse 4203') {
                    currentBooks = ['kenneth_rosen_8th_ed'];
                  }
                });
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Books',
                border: const OutlineInputBorder(),
              ),
              value: _selectedBook,
              items: currentBooks.map((book) {
                return DropdownMenuItem<String>(
                  value: book,
                  child: Text(book),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedBook = value;
                });
                imageUrl = await getImageUrl(value);
                setState(() {}); // Refresh UI to display the image
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
                  ElevatedButton.icon(
                    onPressed: downloadImage,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
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

  Future<String?> getImageUrl(String? bookTitle) async {
    if (_selectedDepartment == null ||
        _selectedProgram == null ||
        _selectedSemester == null ||
        _selectedCourse == null ||
        bookTitle == null) return null;

    final path = 'Library/Books/${_selectedDepartment!}/${_selectedProgram!}/${_selectedSemester!}/${_selectedCourse!}/$bookTitle.png';
    print('Fetching image URL for path: $path');

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
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
          '${directory.parent.parent.parent.parent.path}/Download/BetterSIS/Course Materials');

      if (!await customPath.exists()) {
        await customPath.create(recursive: true);
      }

      final filePath = '${customPath.path}/${_selectedCourse}_${_selectedBook}.png';

      final response = await http.get(Uri.parse(imageUrl!));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ShowMessage.success(context, 'Course material downloaded to: $filePath');
    } catch (e) {
      print('Error downloading image: $e');
      ShowMessage.error(context, 'Failed to download course material');
    }
  }
}

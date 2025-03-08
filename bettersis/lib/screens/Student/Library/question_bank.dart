import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:bettersis/modules/show_message.dart';
import 'package:bettersis/screens/Student/Library/upload_question.dart';

class QuestionBankPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;
  final bool isCr;

  const QuestionBankPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
    required this.isCr,
  }) : super(key: key);

  @override
  _QuestionBankPageState createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedYear;
  String? _selectedExam;
  String? _selectedCourse;
  String? _existingQuestionUrl;
  bool _isCheckingQuestion = false;

  final Map<String, List<String>> programsByDept = {
    'cse': ['cse', 'swe'],
    'eee': ['eee'],
    'mpe': ['me', 'ipe'],
    'cee': ['cee'],
    'btm': ['btm'],
  };

  final List<String> departments = ['cse', 'eee', 'mpe', 'cee', 'btm'];
  final List<String> semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];
  final List<String> years = ['2020-21', '2021-22', '2022-23'];
  final List<String> exams = ['quiz 1', 'quiz 2', 'quiz 3', 'quiz 4', 'mid', 'final'];

  final Map<String, Map<String, Map<String, List<String>>>> coursesByDeptAndSemester = {
    'cse': {
      'cse': {
        '5th': ['CSE 4513'],
      }
    }
  };

  void _resetForm() {
    setState(() {
      _selectedDepartment = null;
      _selectedProgram = null;
      _selectedSemester = null;
      _selectedYear = null;
      _selectedExam = null;
      _selectedCourse = null;
      _existingQuestionUrl = null;
    });
  }

  List<String> _getPrograms() {
    return _selectedDepartment != null 
        ? programsByDept[_selectedDepartment]! 
        : [];
  }

  List<String> _getCourses() {
    if (_selectedDepartment == null || 
        _selectedProgram == null || 
        _selectedSemester == null) return [];

    return coursesByDeptAndSemester[_selectedDepartment]?[_selectedProgram]?[_selectedSemester] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Question Bank',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              items: departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                  _selectedProgram = null;
                  _selectedSemester = null;
                  _selectedYear = null;
                  _selectedExam = null;
                  _selectedCourse = null;
                  _existingQuestionUrl = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Program',
                border: OutlineInputBorder(),
              ),
              value: _selectedProgram,
              items: _getPrograms().map((program) {
                return DropdownMenuItem(
                  value: program,
                  child: Text(program.toUpperCase()),
                );
              }).toList(),
              onChanged: _selectedDepartment == null ? null : (value) {
                setState(() {
                  _selectedProgram = value;
                  _selectedSemester = null;
                  _selectedYear = null;
                  _selectedExam = null;
                  _selectedCourse = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
              value: _selectedSemester,
              items: semesters.map((semester) {
                return DropdownMenuItem(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: _selectedProgram == null ? null : (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedYear = null;
                  _selectedExam = null;
                  _selectedCourse = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              value: _selectedYear,
              items: years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: _selectedSemester == null ? null : (value) {
                setState(() {
                  _selectedYear = value;
                  _selectedExam = null;
                  _selectedCourse = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Exam',
                border: OutlineInputBorder(),
              ),
              value: _selectedExam,
              items: exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam.toUpperCase()),
                );
              }).toList(),
              onChanged: _selectedYear == null ? null : (value) {
                setState(() {
                  _selectedExam = value;
                  _selectedCourse = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
              value: _selectedCourse,
              items: _getCourses().map((course) {
                return DropdownMenuItem(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: _selectedExam == null ? null : (value) {
                setState(() {
                  _selectedCourse = value;
                });
                fetchImageUrl();
              },
            ),
            const SizedBox(height: 24),
            
            // Question Preview or Loading indicator or "No question" message
            if (_isCheckingQuestion) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
            ] else if (_existingQuestionUrl != null) ...[
              Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Image.network(
                      _existingQuestionUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: downloadImage,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Question Paper'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              )
            ] else if (_selectedCourse != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No question paper found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadQuestionPage(
                      userDept: widget.userDept,
                      onLogout: widget.onLogout,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: theme.primaryColor,
            )
    );
  }

  Future<void> fetchImageUrl() async {
    if (_selectedDepartment == null ||
        _selectedProgram == null ||
        _selectedSemester == null ||
        _selectedYear == null ||
        _selectedExam == null ||
        _selectedCourse == null) return;

    setState(() {
      _isCheckingQuestion = true;
    });

    try {
      // Update the path structure to match the storage
      final path = 'Library/questions/${_selectedDepartment}/${_selectedProgram}/${_selectedSemester}/${_selectedYear}/${_selectedExam}/${_selectedCourse}/question.jpg';
      print('Fetching image URL for path: $path');

      final ref = FirebaseStorage.instance.ref().child(path);
      _existingQuestionUrl = await ref.getDownloadURL();
      setState(() {
        _isCheckingQuestion = false;
      });
    } catch (e) {
      print('Error fetching image URL: $e');
      _existingQuestionUrl = null;
      setState(() {
        _isCheckingQuestion = false;
      });
    }
  }

  Future<void> downloadImage() async {
    if (_existingQuestionUrl == null) return;

    try {
      // Request permission to access storage
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to download files')),
        );
        return;
      }

      // Get directory to save the file
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ShowMessage.error(context, 'Failed to access storage');
        return;
      }

      final customPath = Directory(
          '${directory.parent.parent.parent.parent.path}/Download/BetterSIS/Questions');

      if (!await customPath.exists()) {
        await customPath.create(recursive: true);
      }

      final filePath = '${customPath.path}/${_selectedCourse}_${_selectedExam}_${_selectedYear}.png';

      // Download the image
      final response = await http.get(Uri.parse(_existingQuestionUrl!));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ShowMessage.success(context, 'Question paper downloaded to: $filePath');
    } catch (e) {
      print('Error downloading image: $e');
      ShowMessage.error(context, 'Failed to download question paper');
    }
  }
}

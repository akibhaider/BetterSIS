import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:bettersis/modules/show_message.dart';
import 'package:bettersis/screens/Student/Library/upload_course_materials.dart';

class CourseMaterialsPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;
  final bool isCr;

  const CourseMaterialsPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
    required this.isCr,
  }) : super(key: key);

  @override
  _CourseMaterialsPageState createState() => _CourseMaterialsPageState();
}

class _CourseMaterialsPageState extends State<CourseMaterialsPage> {
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  String? _existingMaterialUrl;
  bool _isCheckingMaterial = false; // Add this flag to track when we're checking for materials

  final Map<String, List<String>> programsByDept = {
    'cse': ['cse', 'swe'],
    'eee': ['eee'],
    'mpe': ['me', 'ipe'],
    'cee': ['cee'],
    'btm': ['btm'],
  };

  final List<String> departments = ['cse', 'eee', 'mpe', 'cee', 'btm'];
  final List<String> semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];

  // Predefined courses (add more as needed)
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
      _selectedCourse = null;
      _existingMaterialUrl = null;
      _isCheckingMaterial = false;
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

  Future<void> _checkExistingMaterial() async {
    if (_selectedDepartment == null || 
        _selectedProgram == null || 
        _selectedSemester == null || 
        _selectedCourse == null) {
      return;
    }

    setState(() {
      _isCheckingMaterial = true; // Set flag to true when starting to check
    });

    try {
      final storagePath = 'Library/course_materials/${_selectedDepartment}/${_selectedProgram}/${_selectedSemester}/${_selectedCourse}/material.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      final url = await storageRef.getDownloadURL();
      setState(() {
        _existingMaterialUrl = url;
        _isCheckingMaterial = false; // Reset flag after checking
      });
    } catch (e) {
      setState(() {
        _existingMaterialUrl = null;
        _isCheckingMaterial = false; // Reset flag after checking
      });
    }
  }

  Future<void> _downloadMaterial() async {
    if (_existingMaterialUrl == null) return;

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ShowMessage.error(context, 'Storage permission is required to download files');
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

      final filePath = '${customPath.path}/${_selectedDepartment}_${_selectedProgram}_${_selectedSemester}_${_selectedCourse}.jpg';

      final response = await http.get(Uri.parse(_existingMaterialUrl!));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ShowMessage.success(context, 'Course material downloaded successfully');
    } catch (e) {
      print('Error downloading material: $e');
      ShowMessage.error(context, 'Failed to download course material');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Course Materials',
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

            // Department Dropdown
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
                  _selectedCourse = null;
                  _existingMaterialUrl = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Program Dropdown
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
                  _selectedCourse = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Semester Dropdown
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
                  _selectedCourse = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Course Dropdown
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
              onChanged: _selectedSemester == null ? null : (value) {
                setState(() {
                  _selectedCourse = value;
                });
                _checkExistingMaterial();
              },
            ),
            const SizedBox(height: 24),

            // Material Preview or Loading indicator or "No materials" message
            if (_isCheckingMaterial) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
            ] else if (_existingMaterialUrl != null) ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.network(
                  _existingMaterialUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _downloadMaterial,
                icon: const Icon(Icons.download),
                label: const Text('Download Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ] else if (_selectedCourse != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No materials uploaded by CR',
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
      floatingActionButton: widget.isCr
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadCourseMaterialsPage(
                      userDept: widget.userDept,
                      onLogout: widget.onLogout,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: theme.primaryColor,
            )
          : null,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:bettersis/modules/show_message.dart';

class UploadCourseMaterialsPage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const UploadCourseMaterialsPage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _UploadCourseMaterialsPageState createState() => _UploadCourseMaterialsPageState();
}

class _UploadCourseMaterialsPageState extends State<UploadCourseMaterialsPage> {
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedCourse;
  File? _selectedImage;
  bool _isUploading = false;
  String? _existingMaterialUrl;

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
      _selectedImage = null;
      _existingMaterialUrl = null;
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

    try {
      final storagePath = 'Library/course_materials/${_selectedDepartment}/${_selectedProgram}/${_selectedSemester}/${_selectedCourse}/material.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      final url = await storageRef.getDownloadURL();
      setState(() {
        _existingMaterialUrl = url;
      });
    } catch (e) {
      setState(() {
        _existingMaterialUrl = null;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_selectedDepartment == null || 
        _selectedProgram == null || 
        _selectedSemester == null || 
        _selectedCourse == null) {
      ShowMessage.error(context, 'Please fill all fields before selecting an image');
      return;
    }

    if (_existingMaterialUrl != null) {
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('A course material already exists. Do you want to overwrite it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );

      if (shouldOverwrite != true) return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadMaterial() async {
    if (_selectedDepartment == null || 
        _selectedProgram == null || 
        _selectedSemester == null || 
        _selectedCourse == null || 
        _selectedImage == null) {
      ShowMessage.error(context, 'Please fill all fields and select an image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final storagePath = 'Library/course_materials/${_selectedDepartment}/${_selectedProgram}/${_selectedSemester}/${_selectedCourse}';
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$storagePath/material.jpg');
      
      await storageRef.putFile(_selectedImage!);

      ShowMessage.success(context, 'Course material uploaded successfully');
      Navigator.pop(context); // Return to previous screen after successful upload
    } catch (e) {
      print('Error uploading material: $e');
      ShowMessage.error(context, 'Error uploading material');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Upload Course Material',
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

            // Existing Material Preview
            if (_existingMaterialUrl != null) ...[
              const Text(
                'Current Material:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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
            ],

            // Select Image Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Material Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
            ),

            // New Image Preview
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              const Text(
                'New Material:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton(
              onPressed: _isUploading || _selectedImage == null ? null : _uploadMaterial,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Material'),
            ),
          ],
        ),
      ),
    );
  }
} 
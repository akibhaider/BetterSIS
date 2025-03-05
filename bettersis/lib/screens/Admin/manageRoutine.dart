import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:bettersis/modules/show_message.dart';

class ManageRoutinePage extends StatefulWidget {
  final VoidCallback onLogout;

  const ManageRoutinePage({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  _ManageRoutinePageState createState() => _ManageRoutinePageState();
}

class _ManageRoutinePageState extends State<ManageRoutinePage> {
  String? _selectedDepartment;
  String? _selectedSemester;
  String? _selectedProgram;
  String? _selectedSection;
  File? _selectedImage;
  bool _isUploading = false;
  String? _existingRoutineUrl;

  final Map<String, List<String>> programsByDept = {
    'cse': ['cse', 'swe'],
    'eee': ['eee'],
    'mpe': ['me', 'ipe'],
    'cee': ['cee'],
    'btm': ['btm'],
  };

  final Map<String, List<String>> sectionsByProgram = {
    'cse': ['1', '2'],
    'swe': ['1'],
    'eee': ['1', '2', '3'],
    'cee': ['1', '2'],
    'me': ['1', '2'],
    'ipe': ['1'],
    'btm': ['1'],
  };

  final List<String> departments = ['cse', 'eee', 'mpe', 'cee', 'btm'];
  final List<String> semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];

  @override
  void initState() {
    super.initState();
    _existingRoutineUrl = null;
  }

  void _resetForm() {
    setState(() {
      _selectedDepartment = null;
      _selectedSemester = null;
      _selectedProgram = null;
      _selectedSection = null;
      _selectedImage = null;
      _existingRoutineUrl = null;
    });
  }

  List<String> _getPrograms() {
    return _selectedDepartment != null 
        ? programsByDept[_selectedDepartment]! 
        : [];
  }

  List<String> _getSections() {
    return _selectedProgram != null 
        ? sectionsByProgram[_selectedProgram]! 
        : [];
  }

  Future<void> _checkExistingRoutine() async {
    if (_selectedDepartment == null || 
        _selectedSemester == null || 
        _selectedProgram == null || 
        _selectedSection == null) {
      return;
    }

    try {
      final storagePath = 'Class-Routine/${_selectedDepartment}/${_selectedSemester}/${_selectedProgram}/${_selectedSection}/class_routine.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      final url = await storageRef.getDownloadURL();
      setState(() {
        _existingRoutineUrl = url;
      });
    } catch (e) {
      setState(() {
        _existingRoutineUrl = null;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_selectedDepartment == null || 
        _selectedSemester == null || 
        _selectedProgram == null || 
        _selectedSection == null) {
      ShowMessage.error(context, 'Please fill all fields before selecting an image');
      return;
    }

    if (_existingRoutineUrl != null) {
      // Show confirmation dialog for overwriting
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('A routine already exists for this selection. Do you want to overwrite it?'),
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

  Future<void> _uploadRoutine() async {
    if (_selectedDepartment == null || 
        _selectedSemester == null || 
        _selectedProgram == null || 
        _selectedSection == null || 
        _selectedImage == null) {
      ShowMessage.error(context, 'Please fill all fields and select a routine image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create the storage path
      final storagePath = 'Class-Routine/${_selectedDepartment}/${_selectedSemester}/${_selectedProgram}/${_selectedSection}';
      
      // Create reference to the storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$storagePath/class_routine.jpg');
      
      // Upload the image
      await storageRef.putFile(_selectedImage!);

      ShowMessage.success(context, 'Routine uploaded successfully');
      _clearForm();
    } catch (e) {
      print('Error uploading routine: $e');
      ShowMessage.error(context, 'Error uploading routine: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme('admin');

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Manage Routine',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reset Button
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
                  _selectedSection = null;
                  _existingRoutineUrl = null;
                  _selectedImage = null;
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
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
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
                  _selectedSection = null;
                  _selectedImage = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Section Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Section',
                border: OutlineInputBorder(),
              ),
              value: _selectedSection,
              items: _getSections().map((section) {
                return DropdownMenuItem(
                  value: section,
                  child: Text('Section $section'),
                );
              }).toList(),
              onChanged: _selectedProgram == null ? null : (value) {
                setState(() {
                  _selectedSection = value;
                  _selectedImage = null;
                });
                _checkExistingRoutine(); // Check for existing routine when section is selected
              },
            ),
            const SizedBox(height: 24),

            // Existing Routine Preview
            if (_existingRoutineUrl != null) ...[
              const Text(
                'Current Routine:',
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
                  _existingRoutineUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Error loading image'));
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Select Image Button
            ElevatedButton.icon(
              onPressed: _selectedDepartment != null &&
                        _selectedSemester != null &&
                        _selectedProgram != null &&
                        _selectedSection != null
                  ? _pickImage
                  : null,
              icon: const Icon(Icons.image),
              label: const Text('Select Routine Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
            ),

            // New Image Preview
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              const Text(
                'New Routine:',
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
              onPressed: _isUploading || _selectedImage == null ? null : _uploadRoutine,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Routine'),
            ),
          ],
        ),
      ),
    );
  }
} 
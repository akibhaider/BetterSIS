import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:bettersis/modules/show_message.dart';

class ExamSeatPlanPage extends StatefulWidget {
  final VoidCallback onLogout;

  const ExamSeatPlanPage({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  _ExamSeatPlanPageState createState() => _ExamSeatPlanPageState();
}

class _ExamSeatPlanPageState extends State<ExamSeatPlanPage> {
  String? _selectedYear;
  String? _selectedSemester;
  String? _selectedExam;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isUploading = false;

  final List<String> academicYears = [
    '2020-21', '2021-22', '2022-23', '2023-24', '2024-25',
    '2025-26', '2026-27', '2027-28', '2028-29', '2029-30'
  ];
  final List<String> semesters = ['winter', 'summer'];
  final List<String> exams = ['mid', 'final'];

  @override
  void initState() {
    super.initState();
  }

  void _resetForm() {
    setState(() {
      _selectedYear = null;
      _selectedSemester = null;
      _selectedExam = null;
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _checkExistingSeatPlan() async {
    if (_selectedYear == null || 
        _selectedSemester == null || 
        _selectedExam == null) {
      return;
    }

    try {
      final storagePath = 'ExamSeatPlan/${_selectedYear}/${_selectedSemester}/${_selectedExam}/seat_plan.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      final url = await storageRef.getDownloadURL();
      setState(() {
        _existingImageUrl = url;
      });
    } catch (e) {
      setState(() {
        _existingImageUrl = null;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_selectedYear == null || 
        _selectedSemester == null || 
        _selectedExam == null) {
      ShowMessage.error(context, 'Please fill all fields before selecting an image');
      return;
    }

    if (_existingImageUrl != null) {
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('A seat plan already exists for this selection. Do you want to overwrite it?'),
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

  Future<void> _uploadSeatPlan() async {
    if (_selectedYear == null || 
        _selectedSemester == null || 
        _selectedExam == null || 
        _selectedImage == null) {
      ShowMessage.error(context, 'Please fill all fields and select an image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final storagePath = 'ExamSeatPlan/${_selectedYear}/${_selectedSemester}/${_selectedExam}/seat_plan.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      await storageRef.putFile(_selectedImage!);

      ShowMessage.success(context, 'Seat plan uploaded successfully');
      _resetForm();
    } catch (e) {
      ShowMessage.error(context, 'Error uploading seat plan: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme('admin');

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Exam Seat Plan',
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

            // Academic Year Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Academic Year',
                border: OutlineInputBorder(),
              ),
              value: _selectedYear,
              items: academicYears.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                  _selectedImage = null;
                });
                _checkExistingSeatPlan();
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
                  _selectedImage = null;
                });
                _checkExistingSeatPlan();
              },
            ),
            const SizedBox(height: 16),

            // Exam Dropdown
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
              onChanged: (value) {
                setState(() {
                  _selectedExam = value;
                  _selectedImage = null;
                });
                _checkExistingSeatPlan();
              },
            ),
            const SizedBox(height: 24),

            // Existing Seat Plan Preview
            if (_existingImageUrl != null) ...[
              const Text(
                'Current Seat Plan:',
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
                  _existingImageUrl!,
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
              onPressed: _selectedYear != null &&
                        _selectedSemester != null &&
                        _selectedExam != null
                  ? _pickImage
                  : null,
              icon: const Icon(Icons.image),
              label: const Text('Select Seat Plan Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
            ),

            // New Image Preview
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              const Text(
                'New Seat Plan:',
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
              onPressed: _isUploading || _selectedImage == null ? null : _uploadSeatPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Seat Plan'),
            ),
          ],
        ),
      ),
    );
  }
} 